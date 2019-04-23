locals {
  baseName = "${substr(sha256(azurerm_resource_group.rg.id), 0, 12)}"
}

# Common properties

variable "resource_group_name" {
  description = "The name of the resource group."
}

variable "location" {
  description = "The location/region where the resources are created."
}

variable "prefix" {
  description = "The Prefix used for resources."
}


# EventHub

variable "subnetIds" {
  description = "IDs of subnets. Event Hub Namespace will only accept connections from these subnets."
  type = "string"
}

variable "partitionCount" {
  description = "The number of partitions must be between 2 and 32. The partition count is not changeable."
  type = "string"
}
variable "messageRetentionInDays" {
  description = "The Event Hubs Standard tier allows message retention period for a maximum of seven days."
  type = "string"
}

# Databricks Workspace

variable "vnetId" {
  description = "Resource ID of the VNET that Databricks will use for deploying clusters."
  type = "string"
}

variable "databricksPrivateSubnetName" {
  description = "Name of the subnet to be used for cluster-internal communication"
  type = "string"
}

variable "databricksPublicSubnetName" {
  description = "Name of the subnet to be used for communication outside the cluster"
  type = "string"
}

# Key Vault

variable "keyVaultId" {
  description = "Resource ID of the Key Vault to be used for storing application secrets."
  "type" = "string"
}