#!make
# VPC Creation
-include ../config/properties.mk
.DEFAULT_GOAL := help
help:
	@echo Deploy VPC
	@echo "make [ validate | deploy ]"

validate:
	# Validate the cloudformation template
	aws cloudformation validate-template --template-body file://vpc_sample.yaml

deploy:
	# Create the VPC
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./vpc_sample.yaml  \
      --parameter-overrides "EnvironmentName=${PROJECT_TAG}" \
      --stack-name ${VPC_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
