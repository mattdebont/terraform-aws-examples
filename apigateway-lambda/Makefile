ifndef ENVTYPE
$(error ENVTYPE is not set)
endif

ifndef ENVNAME
$(error ENVNAME is not set)
endif

init:
	rm -rf .terraform
	terraform get
	terraform init -backend-config=backend/backend.$(ENVNAME).tfvars \
	
plan: init
	terraform plan -var-file=tfvars/$(ENVNAME).tfvars

apply: init
	terraform apply -var-file=tfvars/$(ENVNAME).tfvars

plan-destroy: init
	terraform plan -destroy -var-file=tfvars/$(ENVNAME).tfvars

destroy: plan-destroy
	terraform destroy -var-file=tfvars/$(ENVNAME).tfvars

