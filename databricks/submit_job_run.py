import argparse
import json
import os.path
from base64 import b64encode

import requests
from adal import AuthenticationContext

from config import Config
from aad_authentication import get_authorization_code

parser = argparse.ArgumentParser()
parser.add_argument("-c", action="store", dest="config_file", help="Pass the JSON config file to use")


class DatabricksAuthenticationClient:
    refresh_token_file = "refresh_token.txt"
    databricks_resource_id = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

    def __init__(self, config):
        self.config = config
        self.authority_url = "https://login.microsoftonline.com/" + self.config.tenant_id
        self.databricks_base_url = "%s/api/2.0" % self.config.databricks_host_url
        self.databricks_workspace_resource_id = "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Databricks/workspaces/%s" % (
            self.config.subscription_id,
            self.config.databricks_resource_group_name,
            self.config.databricks_workspace_name
        )

    def _get_token_from_auth_code(self):
        auth_code = get_authorization_code(self.config, self.databricks_resource_id)
        context = AuthenticationContext(self.authority_url)

        if self.config.client_id != "":
            token_response = context.acquire_token_with_authorization_code(
                auth_code['code'],
                auth_code['reply_url'],
                self.databricks_resource_id,
                self.config.client_id,
                client_secret=self.config.client_secret
            )
        else:
            token_response = context.acquire_token_with_authorization_code(
                auth_code['code'],
                auth_code['reply_url'],
                self.databricks_resource_id,
                self.config.client_id
            )

        with open(self.refresh_token_file, "w") as f:
            f.write(token_response["refreshToken"])

        return token_response["accessToken"]

    def _get_token_from_refresh(self):
        with open(self.refresh_token_file, "r") as f:
            refresh_token = f.read()

        context = AuthenticationContext(self.authority_url)

        if self.config.client_secret != "":
            token_response = context.acquire_token_with_refresh_token(
                refresh_token,
                self.config.client_id,
                self.databricks_resource_id,
                client_secret=self.config.client_secret)
        else:
            token_response = context.acquire_token_with_refresh_token(
                refresh_token,
                self.config.client_id,
                self.databricks_resource_id)

        return token_response["accessToken"]

    def get_databricks_token(self):
        if os.path.isfile(self.refresh_token_file):
            bearer_token = self._get_token_from_refresh()
        else:
            bearer_token = self._get_token_from_auth_code()

        headers = {
            "Authorization": "Bearer " + bearer_token,
            "X-Databricks-Azure-Workspace-Resource-Id": self.databricks_workspace_resource_id,
        }

        body = {
            "lifetime_seconds": 3600
        }

        response = requests.post(
            self.databricks_base_url + "/token/create",
            data=json.dumps(body),
            headers=headers
        ).json()

        return response["token_value"]


class DatabricksClient(object):
    POST_VERB = "POST"

    def __init__(self, access_token, config):
        self.access_token = access_token
        self.databricks_base_url = "%s/api/2.0" % config.databricks_host_url

    def send_request(self, verb, rest_path, body):
        headers = {
            "Authorization": "Bearer " + self.access_token
        }

        response = requests.request(
            verb,
            self.databricks_base_url + rest_path,
            data=json.dumps(body),
            headers=headers
        ).json()

        return response

    def import_notebook(self, source_path, target_path):
        with open(source_path, "rb") as f:
            # import_workspace must take content that is typed str.
            content = b64encode(f.read()).decode()
            language = self._get_language_from_file(source_path)

            body = {
                "path": target_path,
                "format": "SOURCE",
                "language": language,
                "overwrite": "true",
                "content": content
            }

            return self.send_request(self.POST_VERB, "/workspace/import", body)

    @staticmethod
    def _get_language_from_file(path):
        extensions = {
            'PYTHON': '.py',
            'SCALA': 'scala'
        }

        for language in extensions:
            if path.endswith(extensions[language]):
                return language

    def create_directory(self, path):
        body = {
            "path": path,
        }

        return self.send_request(self.POST_VERB, "/workspace/mkdirs", body)

    def submit_jobs(self, source_path):
        file_names = os.listdir(source_path)
        for filename in file_names:
            with open(os.path.join(source_path, filename), "rb") as job:
                body = json.load(job)
                print(self.send_request(self.POST_VERB, "/jobs/runs/submit", body))

    def import_workspace_directory(self, source_path, target_path):
        filenames = os.listdir(source_path)
        for filename in filenames:
            current_source = os.path.join(source_path, filename)
            # don"t use os.path.join here since it will set \ on Windows
            destination = target_path.rstrip("/") + "/" + filename
            if os.path.isdir(current_source):
                self.import_workspace_directory(current_source, destination)
            elif os.path.isfile(current_source):
                self.import_notebook(current_source, destination)


if __name__ == "__main__":
    args = parser.parse_args()
    databricks_config = Config() if args.config_file is None else Config(args.config_file)
    token = DatabricksAuthenticationClient(databricks_config).get_databricks_token()

    client = DatabricksClient(token, databricks_config)
    client.create_directory("/notebooks")
    client.import_workspace_directory("./notebooks", "/notebooks")
    print(client.submit_jobs("./jobs"))
