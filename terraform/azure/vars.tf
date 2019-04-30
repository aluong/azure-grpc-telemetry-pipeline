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

variable "infra_sandbox_subnet_id" {
  description = "Name of the subnet to be used for the sandbox"
  type = "string"
}

# VM 

variable "custom_image_id" {
  description = "Custom VM image resourceId"
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

variable "event_hub_subnet_ids" {
  description = "IDs of subnets. Event Hub Namespace will only accept connections from these subnets."
  type = "string"
}

variable "partition_count" {
  description = "The number of partitions must be between 2 and 32. The partition count is not changeable."
  type = "string"
  default = "4"
}
variable "message_retention_in_days" {
  description = "The Event Hubs Standard tier allows message retention period for a maximum of seven days."
  type = "string"
  default = "7"
}

# Databricks Workspace

variable "databricks_vnet_id" {
  description = "Resource ID of the VNET that Databricks will use for deploying clusters."
  type = "string"
}

variable "databricks_private_subnet_name" {
  description = "Name of the subnet to be used for cluster-internal communication"
  type = "string"
}

variable "databricks_public_subnet_name" {
  description = "Name of the subnet to be used for communication outside the cluster"
  type = "string"
}

# Key Vault

variable "key_vault_id" {
  description = "Resource ID of the Key Vault to be used for storing application secrets."
  "type" = "string"
}