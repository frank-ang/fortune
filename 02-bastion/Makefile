#!make
# Deploy the Bastion Host
-include ../config/properties.mk
TEMPLATE_FILE := bastion_host.yaml
VPC_ID        := $(shell aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id VPC \
				| jq -r '.StackResources[0].PhysicalResourceId')
SUBNET_ID     := $(shell aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id PublicSubnet1 \
				| jq -r '.StackResources[0].PhysicalResourceId')
AZ            := $(shell aws ec2 describe-subnets --subnet-ids ${SUBNET_ID} \
				| jq -r '.Subnets[0].AvailabilityZone')
BASTION_SECURITY_GROUP := $(shell aws cloudformation describe-stack-resources \
		--stack-name $(VPC_STACK_NAME) --logical-resource-id BastionSecurityGroup \
		| jq -r '.StackResources[0].PhysicalResourceId')

.DEFAULT_GOAL := help
help:
	@echo Deploys the bastion host.
	@echo make validate deploy 

validate: 
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

deploy: dump validate
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./${TEMPLATE_FILE}  \
      --parameter-overrides "VPC=${VPC_ID}" "AZ=${AZ}" "SubnetId=${SUBNET_ID}" \
         "KeyPair=${KEY_PAIR}" "BastionSecurityGroup=${BASTION_SECURITY_GROUP}" \
      --stack-name ${BASTION_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
