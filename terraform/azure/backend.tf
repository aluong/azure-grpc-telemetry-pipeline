terraform {
    backend "azurerm" {
        container_name = "terraform"
        key = "azure.terraform.tfstate"
    }
}