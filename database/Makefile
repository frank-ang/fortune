#!make
# Deploy the Aurora Database
TEMPLATE_FILE := aurora-mysql-serverless.yaml
STACK_NAME    := playground-database
VPC_STACK_NAME:= playground-vpc
PROJECT_TAG   := playground

VPC_ID        := $(shell aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id VPC \
				| jq -r '.StackResources[0].PhysicalResourceId')
SUBNET1       := $(shell aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id PrivateSubnet1 \
				| jq -r '.StackResources[0].PhysicalResourceId')
SUBNET2       := $(shell aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id PrivateSubnet2 \
				| jq -r '.StackResources[0].PhysicalResourceId')
AZ1           := $(shell aws ec2 describe-subnets --subnet-ids ${SUBNET1} \
				| jq -r '.Subnets[0].AvailabilityZone')
AZ2           := $(shell aws ec2 describe-subnets --subnet-ids ${SUBNET2} \
				| jq -r '.Subnets[0].AvailabilityZone')
SECURITY_GROUP := $(shell aws cloudformation describe-stack-resources \
		--stack-name $(VPC_STACK_NAME) --logical-resource-id DbSecurityGroup \
		| jq -r '.StackResources[0].PhysicalResourceId')

dumpvars:
	@echo  VPC_ID: $(VPC_ID)
	@echo  SUBNET1: $(SUBNET1)
	@echo  SUBNET2: $(SUBNET2)
	@echo  AZ1: $(AZ1)
	@echo  AZ2: $(AZ2)
	@echo  SECURITY_GROUP: $(SECURITY_GROUP)

validate:
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

deploy: validate dumpvars
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./$(TEMPLATE_FILE) \
      --parameter-overrides "DatabaseName=playground" \
        "VpcId=$(VPC_ID)" "VpcSecurityGroupId=$(SECURITY_GROUP)" \
        "AZ1=$(AZ1)" "AZ2=$(AZ2)" "SUBNET1=$(SUBNET1)" "SUBNET2=$(SUBNET2)" \
      --stack-name ${STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

loadsampledata:
	# NOTHING