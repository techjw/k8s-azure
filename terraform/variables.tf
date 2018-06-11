variable "bastion_vm_size"  { default = "Standard_B2ms" }
variable "master_vm_size"   { default = "Standard_B2ms" }
variable "worker_vm_size"   { default = "Standard_B2ms" }
variable "worker_count"     { default = 2 }

variable "azure_region" { default = "eastus" }
variable "vnet_cidr"    { default = "10.1.0.0/24" }
variable "local_cidr"   { default = "127.0.0.1/32" }
variable "ssh_key"      { default = "../ssh/cluster.pem.pub" }

variable "adminuser" { default = "kubeuser" }

variable "tenant_id" { default = "your_tenant_id" }
variable "subscription_id" { default = "your_subscription_id" }
variable "client_id" { default = "your_client_id" }
variable "client_secret" { default = "your_client_secret" }

variable "environment"  { default = "testing" }
variable "project"      { default = "k8s" }
