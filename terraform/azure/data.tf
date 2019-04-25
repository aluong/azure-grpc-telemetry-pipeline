# Custom vm image
data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

# Subnet for Virtual Machine and Event Hub

data "azurerm_subnet" "sandbox" {
  name                 = "${var.infra_sandbox_subnet_name}"
  virtual_network_name = "${var.infra_virtual_network_name}"
  resource_group_name  = "${var.infra_resource_group_name}"
}