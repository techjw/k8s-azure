resource "azurerm_public_ip" "k8smaster" {
  name                         = "k8smaster"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.kubernetes.name}"
  public_ip_address_allocation = "static"
  tags {
      environment = "${var.env_tag}"
  }
}

resource "azurerm_network_interface" "k8smaster" {
  name                      = "k8smaster"
  location                  = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name       = "${azurerm_resource_group.kubernetes.name}"
  network_security_group_id = "${azurerm_network_security_group.kubernetes.id}"
  ip_configuration {
    name                          = "k8smaster"
    subnet_id                     = "${azurerm_subnet.kubernetes.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.k8smaster.id}"
  }
  tags {
      environment = "${var.env_tag}"
  }
}

resource "azurerm_virtual_machine" "k8smaster" {
  name                  = "k8smaster"
  location              = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name   = "${azurerm_resource_group.kubernetes.name}"
  network_interface_ids = ["${azurerm_network_interface.k8smaster.id}"]
  vm_size               = "${var.master_vm_size}"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "k8smaster"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8smaster"
    admin_username = "${var.adminuser}"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path      = "/home/${var.adminuser}/.ssh/authorized_keys"
      key_data  = "${file("${var.ssh_key}")}"
    }]
  }
  tags {
    environment = "${var.env_tag}"
  }
}

# data "azurerm_public_ip" "k8smaster" {
#   name                = "${azurerm_public_ip.k8smaster.name}"
#   resource_group_name = "${azurerm_resource_group.kubernetes.name}"
#   depends_on          = ["azurerm_virtual_machine.k8smaster"]
# }
