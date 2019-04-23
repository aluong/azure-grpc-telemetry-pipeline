resource_group_name = "rg"
location = "westus2"
prefix = "foo"
partitionCount = 4
messageRetentionInDays = 1
subnetIds = "[\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\",\"/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/<SUBNET_NAME>\"]"
vnetId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME>"
databricksPrivateSubnet = "databricks-private"
databricksPublicSubnet = "databricks-public"