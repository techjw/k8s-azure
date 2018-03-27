variable "bastion_vm_size" {
  default = "Standard_B2ms"
}

variable "master_vm_size" {
  default = "Standard_B2ms"
}

variable "worker_vm_size" {
  default = "Standard_B2ms"
}

variable "worker_count" {
  default = 2
}

variable "azure_region" {
  default = "East US"
}

variable "local_ip_cidr" {
  default = "127.0.0.1/32"
}

variable "vnet_cidr" {
  default = "10.1.0.0/24"
}

variable "adminuser" {
  default = "kubeuser"
}

variable "ssh_key" {
  default = "../ssh/cluster.pem.pub"
}

variable "tenant_id" {
  default = "your_tenant_id"
}

variable "subscription_id" {
  default = "your_subscription_id"
}

variable "aadclient_id" {
  default = "your_aadclient_id"
}

variable "aadclient_secret" {
  default = "your_aadclient_secret"
}

variable "env_tag" {
  default = "k8s-apprenda"
}
