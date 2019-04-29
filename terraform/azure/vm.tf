locals {
  virtual_machine_name      = "${var.prefix}-vm"
  virtual_machine_user_name = "azureuser"
}

resource "azurerm_network_interface" "pipeline" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.sandbox.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "pipeline" {
  name                  = "${local.virtual_machine_name}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.pipeline.id}"]
  vm_size               = "${var.vm_size}"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${local.virtual_machine_user_name}"
    admin_password = "${uuid()}"
    custom_data = <<-EOF
BROKERS=${local.eventHubNamespace}.servicebus.windows.net:9093
SECRET_ID=${azurerm_key_vault_secret.writer-pipeline.id}
  EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = "${var.user_identities}"
  }
}