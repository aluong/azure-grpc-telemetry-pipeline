import json


class Config(object):
    """
    This class contains configuration parameters
    """
    def __init__(self, config_file="config.json"):
        with open(config_file, "rt") as conf:
            self.__dict__ = json.loads(conf.read())

    tenant_id = ""
    subscription_id = ""
    client_id = ""
    client_secret = ""
    redirect_uri = ""
    authorization_code = ""
    databricks_workspace_name = ""
    databricks_host_url = ""
    databricks_resource_group_name = ""
