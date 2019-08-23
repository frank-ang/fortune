# shared Makefile parameters and functions

# Update to your environment as required.
PROJECT_TAG=playground
VPC_STACK_NAME=playground-vpc
BASTION_STACK_NAME=playground-bastion
DB_STACK_NAME=playground-database-beta
CONTAINER_STACK_NAME=playground-container
KEY_PAIR=macbook2018
PROPERTIES_FILE=../config/properties.mk.gitignore
ENDPOINT_PARAMETER_NAME="/beta/database/${PROJECT_TAG}/endpoint"
SECRET_NAME="/beta/database/${PROJECT_TAG}/secret"

dump:
	@echo Parameters:
	@echo VPC_ID=$(VPC_ID)
	@echo PUBLIC_SUBNET1=$(PUBLIC_SUBNET1)
	@echo PUBLIC_SUBNET2=$(PUBLIC_SUBNET2)
	@echo PRIVATE_SUBNET1=$(PRIVATE_SUBNET1)
	@echo PRIVATE_SUBNET2=$(PRIVATE_SUBNET2)
	@echo AZ1=$(AZ1)
	@echo AZ2=$(AZ2)
	@echo DMZ_SECURITY_GROUP=$(DB_SECURITY_GROUP)
	@echo APP_SECURITY_GROUP=$(DB_SECURITY_GROUP)
	@echo DB_SECURITY_GROUP=$(DB_SECURITY_GROUP)
	@echo BASTION_INSTANCE=$(BASTION_INSTANCE)
	@echo BASTION_IP=$(BASTION_IP)

init:
	# Set updated parameters into properties file
	@echo "# Dynamically generated properties file." > $(PROPERTIES_FILE)
	@echo "VPC_ID = "`aws cloudformation describe-stack-resources \
				--stack-name ${VPC_STACK_NAME} --logical-resource-id VPC \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "PUBLIC_SUBNET1 = "`aws cloudformation describe-stack-resources \
				--stack-name ${VPC_STACK_NAME} --logical-resource-id PublicSubnet1 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "PUBLIC_SUBNET2 = "`aws cloudformation describe-stack-resources \
				--stack-name ${VPC_STACK_NAME} --logical-resource-id PublicSubnet2 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "PRIVATE_SUBNET1 = "`aws cloudformation describe-stack-resources \
				--stack-name ${VPC_STACK_NAME} --logical-resource-id PrivateSubnet1 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "PRIVATE_SUBNET2 = "`aws cloudformation describe-stack-resources \
				--stack-name ${VPC_STACK_NAME} --logical-resource-id PrivateSubnet2 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "AZ1 =" `aws ec2 describe-subnets --subnet-ids ${PRIVATE_SUBNET1} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> $(PROPERTIES_FILE)
	@echo "AZ2 =" `aws ec2 describe-subnets --subnet-ids ${PRIVATE_SUBNET2} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> ${PROPERTIES_FILE}
	@echo "DMZ_SECURITY_GROUP =" `aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "DmzSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "APP_SECURITY_GROUP =" `aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "AppSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "DB_SECURITY_GROUP =" `aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "DbSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "BASTION_IP =" `aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicIP") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "BASTION_INSTANCE =" `aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "InstanceId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "DB_HOST =" `aws ssm get-parameter --name ${ENDPOINT_PARAMETER_NAME} \
		| jq -r '.Parameter.Value'` >> $(PROPERTIES_FILE)
	@cat $(PROPERTIES_FILE)

config-db-secret:
	$(eval DB_PASSWORD  = $(shell aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} \
					| jq -r '.SecretString' | jq -r '.password'))
