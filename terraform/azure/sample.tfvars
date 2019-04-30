# common
resource_group_name = "azure-pipeline-rg"
location = "westus2"

# infra network
infra_sandbox_subnet_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>/sandbox"

# event hubs
event_hub_subnet_ids = "[\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\",\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\"]"

# databricks
databricks_vnet_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>"
databricks_private_subnet_name = "databricks-private"
databricks_public_subnet_name = "databricks-public"

# virtual machine
custom_image_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Compute/images/<IMAGE_NAME>"
user_identities = ["/subscriptions/<SUBSCRIPTION_ID>/resourcegroups/<RG_NAME>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<USER_ASSIGNED_IDENTITY>"]

# keyvault
key_vault_id = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.KeyVault/vaults/<KEYVAULT_NAME>"