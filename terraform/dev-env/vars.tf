variable "infraRG" {
  type = "string"
}

variable "location" {
  type    = "string"
  default = "westus2"
}

variable "databricks_control_plane" {
  type = "map"

  default = {
    "australiacentral"   = "13.70.105.50/32"
    "australiacentral2"  = "13.70.105.50/32"
    "australiaeast"      = "13.70.105.50/32"
    "australiasoutheast" = "13.70.105.50/32"
    "canadacentral"      = "40.85.223.25/32"
    "canadaeast"         = "40.85.223.25/32"
    "centralindia"       = "104.211.101.14/32"
    "centralus"          = "23.101.152.95/32"
    "eastasia"           = "52.187.0.85/32"
    "eastus"             = "23.101.152.95/32"
    "eastus2"            = "23.101.152.95/32"
    "eastus2euap"        = "23.101.152.95/32"
    "japaneast"          = "13.78.19.235/32"
    "japanwest"          = "13.78.19.235/32"
    "northcentralus"     = "23.101.152.95/32"
    "northeurope"        = "23.100.0.135/32"
    "southcentralus"     = "40.83.178.242/32"
    "southeastasia"      = "52.187.0.85/32"
    "southindia"         = "104.211.101.14/32"
    "uksouth"            = "51.140.203.27/32"
    "ukwest"             = "51.140.203.27/32"
    "westcentralus"      = "40.83.178.242/32"
    "westeurope"         = "23.100.0.135/32"
    "westindia"          = "104.211.101.14/32"
    "westus"             = "40.83.178.242/32"
    "westus2"            = "40.83.178.242/32"
  }
}

variable "databricks_web_app" {
  type = "map"

  default = {
    "australiacentral"   = "13.75.218.172/32"
    "australiacentral2"  = "13.75.218.172/32"
    "australiaeast"      = "13.75.218.172/32"
    "australiasoutheast" = "13.75.218.172/32"
    "canadacentral"      = "13.71.184.74/32"
    "canadaeast"         = "13.71.184.74/32"
    "centralindia"       = "104.211.89.81/32"
    "centralus"          = "40.70.58.221/32"
    "eastasia"           = "52.187.145.107/32"
    "eastus"             = "40.70.58.221/32"
    "eastus2"            = "40.70.58.221/32"
    "eastus2euap"        = "40.70.58.221/32"
    "japaneast"          = "52.246.160.72/32"
    "japanwest"          = "52.246.160.72/32"
    "northcentralus"     = "40.70.58.221/32"
    "northeurope"        = "52.232.19.246/32"
    "southcentralus"     = "40.118.174.12/32"
    "southeastasia"      = "52.187.145.107/32"
    "southindia"         = "104.211.89.81/32"
    "uksouth"            = "51.140.204.4/32"
    "ukwest"             = "51.140.204.4/32"
    "westcentralus"      = "40.118.174.12/32"
    "westeurope"         = "52.232.19.246/32"
    "westindia"          = "104.211.89.81/32"
    "westus"             = "40.118.174.12/32"
    "westus2"            = "40.118.174.12/32"
  }
}
