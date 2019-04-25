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

variable "infra_sandbox_subnet_name" {
  description = "Name of the subnet to be used for the sandbox"
  type = "string"
}

variable "infra_virtual_network_name" {
  description = "Name of the infra virtual network"
  type = "string"
}

variable "infra_resource_group_name" {
  description = "Name of the infra resource group"
  type = "string"
}

# VM 

variable "custom_image_resource_group_name" {
  description = "The resource group for the custom vm image"
  type = "string"
}

variable "custom_image_name" {
  description = "The name of the custom vm image"
  type = "string"
}

variable "vm_size" {
  description = "Size of the vm"
  type = "string"
  default = "Standard_D2_V2"
}

variable "user_identities" {
  description = "User identities assigned to the virtual machine"
  type = "list"
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