provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

resource "azurerm_resource_group" "kubernetes" {
  name     = "${var.project}-${var.environment}-rg"
  location = "${var.azure_region}"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_virtual_network" "kubernetes" {
  name                = "${var.project}-${var.environment}-vnet"
  address_space       = ["${var.vnet_cidr}"]
  location            = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name = "${azurerm_resource_group.kubernetes.name}"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_network_security_group" "kubernetes" {
    name                = "${var.project}-${var.environment}-nsg"
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.kubernetes.name}"
    security_rule {
        name                       = "SSH"
        priority                   = 3001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["${var.vnet_cidr}", "${var.local_cidr}"]
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Kubernetes_API"
        priority                   = 3002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefixes    = ["${var.vnet_cidr}", "${var.local_cidr}"]
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Kubernetes_Ingress"
        priority                   = 3003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefixes    = ["${var.vnet_cidr}", "${var.local_cidr}"]
        destination_address_prefix = "*"
    }
    tags {
      environment = "${var.environment}"
      project = "${var.project}"
    }
}

resource "azurerm_route_table" "kubernetes" {
  name                = "${var.project}-${var.environment}-rt"
  location            = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name = "${azurerm_resource_group.kubernetes.name}"
}

resource "azurerm_subnet" "kubernetes" {
  name                      = "${var.project}-${var.environment}-subnet"
  resource_group_name       = "${azurerm_resource_group.kubernetes.name}"
  virtual_network_name      = "${azurerm_virtual_network.kubernetes.name}"
  address_prefix            = "${var.vnet_cidr}"
  route_table_id            = "${azurerm_route_table.kubernetes.id}"
  network_security_group_id = "${azurerm_network_security_group.kubernetes.id}"
}
