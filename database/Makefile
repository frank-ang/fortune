#!make
# Configure 
TEMPLATE_FILE   := aurora-mysql-serverless.yaml
PROPERTIES_FILE := properties.mk.gitignore
-include ../properties.mk $(PROPERTIES_FILE)

dump:
	@echo Parameters:
	@echo VPC_ID=$(VPC_ID)
	@echo SUBNET1=$(SUBNET1)
	@echo SUBNET2=$(SUBNET2)
	@echo AZ1=$(AZ1)
	@echo AZ2=$(AZ2)
	@echo DB_SECURITY_GROUP=$(DB_SECURITY_GROUP)
	@echo BASTION_INSTANCE=$(BASTION_INSTANCE)
	@echo BASTION_IP=$(BASTION_IP)

init:
	# Set updated parameters into properties file
	@echo "# Dynamically generated properties file." > $(PROPERTIES_FILE)
	@echo "VPC_ID = "`aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id VPC \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "SUBNET1 = "`aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id PrivateSubnet1 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "SUBNET2 = "`aws cloudformation describe-stack-resources \
				--stack-name $(VPC_STACK_NAME) --logical-resource-id PrivateSubnet2 \
				| jq -r '.StackResources[0].PhysicalResourceId'` >> $(PROPERTIES_FILE)
	@echo "AZ1 =" `aws ec2 describe-subnets --subnet-ids ${SUBNET1} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> $(PROPERTIES_FILE)
	@echo "AZ2 =" `aws ec2 describe-subnets --subnet-ids ${SUBNET2} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> $(PROPERTIES_FILE)
	@echo "DB_SECURITY_GROUP =" `aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "DbSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "BASTION_IP =" `aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicIP") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "BASTION_INSTANCE =" `aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "InstanceId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@cat $(PROPERTIES_FILE)

validate:
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}

deploy: validate init dump
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./$(TEMPLATE_FILE) \
      --parameter-overrides "DatabaseName=playground" \
        "VpcId=$(VPC_ID)" "VpcSecurityGroupId=$(DB_SECURITY_GROUP)" \
        "AZ1=$(AZ1)" "AZ2=$(AZ2)" "SUBNET1=$(SUBNET1)" "SUBNET2=$(SUBNET2)" \
      --stack-name ${DB_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

load:
	# Create database tables and load sample CSV data
	$(eval DB_SECRET_ID = $(shell aws cloudformation describe-stacks --stack-name $(DB_STACK_NAME) \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "Secret") | .OutputValue'))
	$(eval DB_PASSWORD  = $(shell aws secretsmanager get-secret-value --secret-id ${DB_SECRET_ID} \
					| jq -r '.SecretString' | jq -r '.password'))
	$(eval DB_HOST = `aws cloudformation describe-stacks --stack-name $(DB_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "Host") | .OutputValue'`)
	@echo "DB_HOST = ${DB_HOST}"
	scp ./quotes.ddl.sql ec2-user@${BASTION_IP}:/tmp
	scp ./quotes.csv ec2-user@${BASTION_IP}:/tmp
	ssh ec2-user@${BASTION_IP} "mysql -u root -p${DB_PASSWORD} -h ${DB_HOST} < /tmp/quotes.ddl.sql"
