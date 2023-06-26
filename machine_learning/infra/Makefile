init:
	terraform get; terraform init;

up:
	terraform apply -var-file=terraform.tfvars -auto-approve;

down:
	terraform destroy -var-file=terraform.tfvars -auto-approve;

dr:
	terraform destroy -var-file=terraform.tfvars -auto-approve -target $(filter-out $@,$(MAKECMDGOALS));