create-keypair:
	test -d ssh || mkdir ssh
	cd ssh && ssh-keygen -t rsa -f cluster.pem -N "" -C "k8s-testing-key"
	chmod 600 ssh/cluster.pem

plan-vms:
	cd terraform && terraform init && terraform plan

create-vms:
	cd terraform && terraform init && terraform apply

destroy-vms:
	cd terraform && terraform init && terraform destroy --force
	cd terraform && rm terraform.tfstate terraform.tfstate.backup

cleanup:
	test -d ssh && rm -r ssh/

# ################################################
# Commands to execute from bastion node
# ################################################

prepare-kubernetes:
	kismatic install validate -f kismatic-cluster.yaml

create-kubernetes:
	kismatic install apply -f kismatic-cluster.yaml --skip-preflight
	cp generated/kubeconfig .
	mkdir ~/.kube/
	cp kubeconfig ~/.kube/config
