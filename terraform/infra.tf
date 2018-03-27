provider "azurerm" {
  version = "~> 1.1"
}

resource "azurerm_resource_group" "kubernetes" {
  name     = "kubernetes"
  location = "${var.azure_region}"
  tags {
      environment = "${var.env_tag}"
  }
}

resource "azurerm_virtual_network" "kubernetes" {
  name                = "kubernetes"
  address_space       = ["${var.vnet_cidr}"]
  location            = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name = "${azurerm_resource_group.kubernetes.name}"
  tags {
      environment = "${var.env_tag}"
  }
}

resource "azurerm_network_security_group" "kubernetes" {
    name                = "kubernetes"
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.kubernetes.name}"
    security_rule {
        name                       = "Internal_SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "${var.vnet_cidr}"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "SSH"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "${var.local_ip_cidr}"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "DenyRandomSSH"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags {
        environment = "${var.env_tag}"
    }
}

resource "azurerm_network_security_group" "kubeapi" {
    name                = "kubeapi"
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.kubernetes.name}"
    security_rule {
        name                       = "Internal_SSH"
        priority                   = 2001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "${var.vnet_cidr}"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "SSH"
        priority                   = 2002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "${var.local_ip_cidr}"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "DenyRandomSSH"
        priority                   = 2003
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "Kubernetes_API"
        priority                   = 2004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "${var.local_ip_cidr}"
        destination_address_prefix = "*"
    }
    tags {
        environment = "${var.env_tag}"
    }
}

resource "azurerm_route_table" "kubernetes" {
  name                = "kubernetes"
  location            = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name = "${azurerm_resource_group.kubernetes.name}"
}

resource "azurerm_subnet" "kubernetes" {
  name                      = "kubernetes"
  resource_group_name       = "${azurerm_resource_group.kubernetes.name}"
  virtual_network_name      = "${azurerm_virtual_network.kubernetes.name}"
  address_prefix            = "${var.vnet_cidr}"
  route_table_id            = "${azurerm_route_table.kubernetes.id}"
  network_security_group_id = "${azurerm_network_security_group.kubernetes.id}"
}
