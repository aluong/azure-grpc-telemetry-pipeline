provider "azurerm" {
  version = "~>1.24"
}

data "azurerm_client_config" "current" {}

locals {
  baseName = "${substr(base64sha256(azurerm_resource_group.rg.id), 0, 12)}"
  kvName   = "kv${local.baseName}"
  vnetName = "vnet${local.baseName}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.infraRG}"
  location = "${var.location}"
}

resource "azurerm_key_vault" "kv" {
  name                = "${local.kvName}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }
}

resource "azurerm_network_security_group" "databricksNSG" {
  name                = "nsg-databricks"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "databricks-control-plane-ssh"
    direction                  = "Inbound"
    priority                   = 100
    access                     = "Allow"
    description                = "Required for Databricks control plane management of worker nodes."
    source_address_prefix      = "${var.databricks_control_plane[azurerm_resource_group.rg.location]}"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "databricks-control-plane-worker-proxy"
    direction                  = "Inbound"
    priority                   = 110
    access                     = "Allow"
    description                = "Required for Databricks control plane communication with worker nodes."
    source_address_prefix      = "${var.databricks_control_plane[azurerm_resource_group.rg.location]}"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "*"
    destination_port_range     = "5557"
  }

  security_rule {
    name                       = "databricks-worker-to-worker-inbound"
    direction                  = "Inbound"
    priority                   = 200
    access                     = "Allow"
    description                = "Required for worker nodes communication within a cluster."
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "databricks-worker-to-webapp"
    direction                  = "Outbound"
    priority                   = 100
    access                     = "Allow"
    description                = "Required for workers communication with Databricks Webapp."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "${var.databricks_web_app[azurerm_resource_group.rg.location]}"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "databricks-worker-to-sql"
    direction                  = "Outbound"
    priority                   = 110
    access                     = "Allow"
    description                = "Required for workers communication with Azure SQL services."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "Sql"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "databricks-worker-to-storage"
    direction                  = "Outbound"
    priority                   = 120
    access                     = "Allow"
    description                = "Required for workers communication with Azure Storage services."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "Storage"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "databricks-worker-to-worker-outbound"
    direction                  = "Outbound"
    priority                   = 130
    access                     = "Allow"
    description                = "Required for worker nodes communication within a cluster."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "databricks-worker-to-any"
    direction                  = "Outbound"
    priority                   = 140
    access                     = "Allow"
    description                = "Required for worker nodes communication with any destination."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_network_security_group" "testNSG" {
  name                = "nsg-test"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-ssh"
    direction                  = "Inbound"
    priority                   = 100
    access                     = "Allow"
    description                = "Allow SSH to test VMs."
    source_address_prefix      = "*"
    source_port_range          = "*"
    protocol                   = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vnetName}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
  service_endpoints    = ["Microsoft.EventHub"]
  network_security_group_id = "${azurerm_network_security_group.testNSG.id}"
}

resource "azurerm_subnet_network_security_group_association" "testNSGAssociation" {
  subnet_id                 = "${azurerm_subnet.test.id}"
  network_security_group_id = "${azurerm_network_security_group.testNSG.id}"
}

resource "azurerm_subnet" "databricks-private" {
  name                 = "databricks-private"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.EventHub"]
  network_security_group_id = "${azurerm_network_security_group.databricksNSG.id}"
}

resource "azurerm_subnet_network_security_group_association" "databricks-privateNSGAssociation" {
  subnet_id                 = "${azurerm_subnet.databricks-private.id}"
  network_security_group_id = "${azurerm_network_security_group.databricksNSG.id}"
}

resource "azurerm_subnet" "databricks-public" {
  name                 = "databricks-public"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.3.0/24"
  network_security_group_id = "${azurerm_network_security_group.databricksNSG.id}"
}

resource "azurerm_subnet_network_security_group_association" "databricks-publicNSGAssociation" {
  subnet_id                 = "${azurerm_subnet.databricks-public.id}"
  network_security_group_id = "${azurerm_network_security_group.databricksNSG.id}"
}
