#!make
# Deploy the Bastion Host
TEMPLATE_FILE := bastion_host.yaml
VPC_STACK_NAME:= playground-vpc
STACK_NAME    := playground-bastion
PROJECT_TAG   := playground
KEY_PAIR      := macbook2018
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

variable_check:
	@# TODO null check on variables
	@echo VPC_ID: ${VPC_ID}
	@echo SUBNET_ID: ${SUBNET_ID}
	@echo AZ: ${AZ}
	@echo BASTION_SECURITY_GROUP: ${BASTION_SECURITY_GROUP}

validate: 
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

deploy: variable_check validate
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./${TEMPLATE_FILE}  \
      --parameter-overrides "VPC=${VPC_ID}" "AZ=${AZ}" "SubnetId=${SUBNET_ID}" \
         "KeyPair=${KEY_PAIR}" "BastionSecurityGroup=${BASTION_SECURITY_GROUP}" \
      --stack-name ${STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
