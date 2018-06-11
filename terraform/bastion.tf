data "template_file" "azure_cloud_provider" {
  template = "${file("${path.module}/user-data/azure-cloud-provider.conf.tpl")}"
  vars {
    tenant_id       = "${var.tenant_id}"
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    az_location     = "${var.azure_region}"
    az_rg           = "${azurerm_resource_group.kubernetes.name}"
    az_vnet         = "${azurerm_virtual_network.kubernetes.name}"
    az_subnet       = "${azurerm_subnet.kubernetes.name}"
    az_nsg          = "${azurerm_network_security_group.kubernetes.name}"
    az_rt           = "${azurerm_route_table.kubernetes.name}"
  }
}

data "template_file" "kismatic_cluster" {
  template = "${file("${path.module}/user-data/kismatic-cluster.yaml.tpl")}"
  vars {
    master_ip     = "${azurerm_network_interface.k8smaster.private_ip_address}"
    node1_ip      = "${azurerm_network_interface.k8sworker.*.private_ip_address[0]}"
    node2_ip      = "${azurerm_network_interface.k8sworker.*.private_ip_address[1]}"
    adminuser     = "${var.adminuser}"
  }
}

resource "azurerm_public_ip" "k8sbastion" {
  name                         = "k8sbastion"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.kubernetes.name}"
  public_ip_address_allocation = "static"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}
resource "azurerm_network_interface" "k8sbastion" {
  name                      = "k8sbastion"
  location                  = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name       = "${azurerm_resource_group.kubernetes.name}"
  ip_configuration {
    name                          = "k8sbastion"
    subnet_id                     = "${azurerm_subnet.kubernetes.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.k8sbastion.id}"
  }
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_virtual_machine" "k8sbastion" {
  name                  = "k8sbastion"
  location              = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name   = "${azurerm_resource_group.kubernetes.name}"
  network_interface_ids = ["${azurerm_network_interface.k8sbastion.id}"]
  vm_size               = "${var.bastion_vm_size}"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "k8sbastion"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8sbastion"
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

  connection {
    type        = "ssh"
    private_key = "${file("${path.module}/../ssh/cluster.pem")}"
    user        = "${var.adminuser}"
    host        = "${azurerm_public_ip.k8sbastion.ip_address}"
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/../ssh/cluster.pem"
    destination = "/home/${var.adminuser}/cluster.pem"
  }

  provisioner "file" {
    content = "${data.template_file.kismatic_cluster.rendered}"
    destination = "/home/${var.adminuser}/kismatic-cluster.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/../Makefile"
    destination = "/home/${var.adminuser}/Makefile"
  }

  provisioner "file" {
    content = "${data.template_file.azure_cloud_provider.rendered}"
    destination = "/home/${var.adminuser}/azure-cloud-provider.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y -q",
      "sudo apt-get install -y -q build-essential git wget"
    ]
  }
  # Fetch and Extract the Kismatic tar file, setup both Kubectl and Helm
  provisioner "remote-exec" {
    inline = [
      "chmod 600 cluster.pem azure-cloud-provider.conf kismatic-cluster.yaml",
      "curl -o kismatic.tar.gz -Ls https://github.com/apprenda/kismatic/releases/download/v1.11.1/kismatic-v1.11.1-linux-amd64.tar.gz",
      "tar zxf kismatic.tar.gz",
      "rm kismatic.tar.gz",
      "sudo cp helm /usr/local/bin/helm",
      "sudo cp kubectl /usr/local/bin/kubectl",
      "echo 'source <(kubectl completion bash)' >> ~/.bashrc",
      "sudo cp kismatic /usr/local/bin/kismatic"
    ]
  }
}
