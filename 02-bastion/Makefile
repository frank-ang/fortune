#!make
# Deploy the Bastion Host
-include ../config/properties.mk
TEMPLATE_FILE := bastion_host.yaml
VPC_ID_DEPRECATED := $(shell aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "VPC") | .OutputValue')

SUBNET_ID_DEPRECATED := $(shell aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicSubnet1") | .OutputValue')
AZ_DEPRECATED := $(shell aws ec2 describe-subnets --subnet-ids ${SUBNET_ID} \
		| jq -r '.Subnets[0].AvailabilityZone')
.DEFAULT_GOAL := help
help:
	@echo Deploys the bastion host.
	@echo "make [ validate | init | deploy ]"

validate: 
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

deploy: validate
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./${TEMPLATE_FILE}  \
      --parameter-overrides "VPC=${VPC_ID}" "AZ=${AZ1}" "SubnetId=${PUBLIC_SUBNET1}" \
         "KeyPair=${KEY_PAIR}" "BastionSecurityGroup=${BASTION_SECURITY_GROUP}" \
      --stack-name ${BASTION_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
