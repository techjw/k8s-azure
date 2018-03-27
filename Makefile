ssh-keypair:
	mkdir ssh
	cd ssh && ssh-keygen -t rsa -f cluster.pem -N ""
	chmod 600 ssh/cluster.pem

plan-cluster-vms:
	cd terraform && terraform init && terraform plan

cluster-vms:
	cd terraform && terraform init && terraform apply

destroy-cluster-vms:
	cd terraform && terraform init && terraform destroy --force

# ################################################
# Commands to execute from bastion node
# ################################################

validate-k8s-cluster:
	kismatic install validate -f kismatic-cluster.yaml

k8s-cluster:
	kismatic install apply -f kismatic-cluster.yaml
	cp generated/kubeconfig .
	mkdir ~/.kube/
	cp kubeconfig ~/.kube/config
