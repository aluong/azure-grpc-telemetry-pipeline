# Running Databricks Jobs

# Prerequisites:
* Databricks Workspace and generated Authentication Token
* Databricks cli is installed (to install run: `pip install databricks-cli`)
* [Azure Key-Vault backed secret scope](https://docs.azuredatabricks.net/user-guide/secrets/secret-scopes.html) in workspace called 'azure-key-vault'

# Run script

Run the databricks script by passing the Databricks Authentication token and host url:

    `./databricks.sh -t <token> -h <host>`
