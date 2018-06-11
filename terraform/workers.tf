resource "azurerm_network_interface" "k8sworker" {
  count = "${var.worker_count}"
  name                = "k8sworker${count.index + 1}"
  location            = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name = "${azurerm_resource_group.kubernetes.name}"
  ip_configuration {
    name                          = "k8sworker${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.kubernetes.id}"
    private_ip_address_allocation = "dynamic"
  }
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_virtual_machine" "k8sworker" {
  count = "${var.worker_count}"
  name                  = "k8sworker${count.index + 1}"
  location              = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name   = "${azurerm_resource_group.kubernetes.name}"
  network_interface_ids = ["${azurerm_network_interface.k8sworker.*.id[count.index]}"]
  vm_size               = "${var.worker_vm_size}"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "k8sworker${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8sworker${count.index + 1}"
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
    environment = "${var.environment}"
    project = "${var.project}"
  }
}
