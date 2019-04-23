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