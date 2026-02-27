.PHONY: tofu-init tofu-plan-dev tofu-apply-dev tofu-plan-prod tofu-apply-prod ansible-dev ansible-prod

TOFU ?= tofu
ANSIBLE_PLAYBOOK ?= ansible-playbook

tofu-init:
	$(TOFU) -chdir=tofu init

tofu-plan-dev: tofu-init
	$(TOFU) -chdir=tofu plan -state=terraform.dev.tfstate --var-file=variables.dev.tfvars

tofu-apply-dev: tofu-init
	$(TOFU) -chdir=tofu apply -state=terraform.dev.tfstate --var-file=variables.dev.tfvars

tofu-destroy-dev: tofu-init
	$(TOFU) -chdir=tofu destroy -state=terraform.dev.tfstate --var-file=variables.dev.tfvars

tofu-plan-prod: tofu-init
	$(TOFU) -chdir=tofu plan -state=terraform.prod.tfstate --var-file=variables.prod.tfvars

tofu-apply-prod: tofu-init
	$(TOFU) -chdir=tofu apply -state=terraform.prod.tfstate --var-file=variables.prod.tfvars

tofu-destroy-prod: tofu-init
	$(TOFU) -chdir=tofu destroy -state=terraform.prod.tfstate --var-file=variables.prod.tfvars

ansible-dev:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/dev/hosts.ini main.yml

reset-ansible-dev:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/dev/hosts.ini reset.yml

post-ansible-dev:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/dev/hosts.ini postconfig.yml

ansible-prod:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/prod/hosts.ini main.yml

post-ansible-prod:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/prod/hosts.ini postconfig.yml

reset-ansible-prod:
	cd ansible && $(ANSIBLE_PLAYBOOK) -i inventory/prod/hosts.ini reset.yml
