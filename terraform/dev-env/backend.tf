terraform {
    backend "azurerm" {
        container_name = "terraform"
        key = "dev-env.terraform.tfstate"
    }
}