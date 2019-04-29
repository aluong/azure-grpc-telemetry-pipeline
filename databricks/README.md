# Running a Databricks Job

# Prerequisites:
* Azure Databricks Workspace
* [Azure Key-Vault backed secret scope](https://docs.azuredatabricks.net/user-guide/secrets/secret-scopes.html) in Databricks workspace called 'azure-key-vault'
* A new python virtual environment
* [Azure app registered with AAD](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v1-add-azure-ad-app). If you use a Web app/API application type instead of a Native application type then you need to provide the client secret in the config.json. 

# Configure app to have permissions to Azure Databricks

1. Add AzureDatabricks to the Required permissions of the registered application. You must be an admin user to perform this step. On the registered application page, go to Settings -> API ACCESS and select Required permissions. Then click Add -> 1 Select an API, search for AzureDatabricks, and select Enable Access.

2. When you have selected AzureDatabricks, click 2 Select permissions. Then select the DELEGATED PERMISSIONS.

3. Click Grant permissions and then Yes. You must be an admin user to perform this step.

# Get Authorization Code from app registration
The authorization code can be obtained by sending an HTTP request in the browser by composing a URL as described in the Microsoft document [Request an authorization code.](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code#request-an-authorization-code)

 An example URL is:

```
// Line breaks for legibility only

https://login.microsoftonline.com/{tenant}/oauth2/authorize?
client_id={client_id}
&response_type=code
&redirect_uri={redirect_uri in encoded format: e.g., http%3A%2F%2Flocalhost}
&response_mode=query
&resource=2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
&state={a random number or some encoded info}
```

Please replace the highlighted fields accordingly

# Run script

1. Fill in the [config.json](./config.json) file. 


2. Activate the new python virtual environment and install the required packages by running:

    `pip install -r requirements.txt`

3. Run the databricks python script:

    If using the default config file there is no need to pass any parameters to the script:
    
    `python submit_job_run.py`

     If using a separate config file, then the path to the config file from the script must be passed as a parameter. For example, if using a custom 'my_config.json' file under the notebooks/ directory the command would look like the following:

    `python submit_job_run.py -c ./notebooks/my_config.json`
