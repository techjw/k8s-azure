output "bastion_ip" {
    value = "${azurerm_network_interface.k8sbastion.private_ip_address}"
}
output "bastion_pubip" {
    value = "${azurerm_public_ip.k8sbastion.ip_address}"
}

output "master_ip" {
    value = "${azurerm_network_interface.k8smaster.private_ip_address}"
}
output "master_pubip" {
    value = "${azurerm_public_ip.k8smaster.ip_address}"
}

output "worker1_ip" {
    value = "${azurerm_network_interface.k8sworker.*.private_ip_address[0]}"
}

output "worker2_ip" {
    value = "${azurerm_network_interface.k8sworker.*.private_ip_address[1]}"
}

output "kube_bastion_login" {
  value = "ssh -i ssh/cluster.pem ${var.adminuser}@${azurerm_public_ip.k8sbastion.ip_address}"
}
