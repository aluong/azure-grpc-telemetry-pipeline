terraform {
    backend "azurerm" {
        container_name = "terraform"
        key = "dev-env.terraform.tfstate"
    }
}

provider "azurerm" {
  version = "~>1.24"
}