# common variables
resource_group_name = "azure-pipeline-rg"
location = "westus2"
prefix = "foo"
partitionCount = 4
messageRetentionInDays = 1

# infra network variables
infra_sandbox_subnet_name = "sandbox"
infra_virtual_network_name = "<VIRTUAL_NETWORK_NAME>"
infra_resource_group_name = "azure-pipeline-infra"

# event hubs variables
subnetIds = "[\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\",\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\"]"
vnetId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>"

# databricks variables
databricksPrivateSubnetName = "databricks-private"
databricksPublicSubnetName = "databricks-public"

# custom vm image variables
custom_image_resource_group_name = "packer-test-resourcegroup-westus2"
custom_image_name = "linuxImage-2019-04-24T00-14-58Z"
user_identities = ["/subscriptions/<SUBSCRIPTION_ID>/resourcegroups/<RG_NAME>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<USER_ASSIGNED_IDENTITY>"]

# keyvault variables
keyVaultId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.KeyVault/vaults/<KEYVAULT_NAME>"