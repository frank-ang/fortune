# shared Makefile parameters and functions for include
include ../config/config.mk

init-deprecated:
	@# TODO: REFACTOR this function into a bash script.
	@# Set updated stack parameters into properties file. 
	@# Variables from Non-existent stacks should be set as blank
	@# the generated file can be included from Makefile, or sourced in a Bash shell.
	@echo "# Dynamically generated properties file." > $(PROPERTIES_FILE)
	@echo "export AWS_REGION="`aws configure get region` >> $(PROPERTIES_FILE)
	@echo "export VPC_ID="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "VPC") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export PUBLIC_SUBNET1="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicSubnet1") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export PUBLIC_SUBNET2="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicSubnet2") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export PRIVATE_SUBNET1="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PrivateSubnet1") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export PRIVATE_SUBNET2="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PrivateSubnet2") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export AZ1="`aws ec2 describe-subnets --subnet-ids ${PRIVATE_SUBNET1} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> $(PROPERTIES_FILE)
	@echo "export AZ2="`aws ec2 describe-subnets --subnet-ids ${PRIVATE_SUBNET2} \
				| jq -r '.Subnets[0].AvailabilityZone'` >> ${PROPERTIES_FILE}
	@echo "export DMZ_SECURITY_GROUP="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "DmzSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export APP_SECURITY_GROUP="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "AppSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export DB_SECURITY_GROUP="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "DbSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export BASTION_IP="`aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicIP") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export BASTION_INSTANCE="`aws cloudformation describe-stacks --stack-name $(BASTION_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "InstanceId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export DB_HOST="`aws ssm get-parameter --name ${DB_ENDPOINT_PARAMETER_NAME} \
		| jq -r '.Parameter.Value'` >> $(PROPERTIES_FILE)
	@echo "export API_ENDPOINT="`aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicLoadBalancerDNSName") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export BASTION_SECURITY_GROUP="`aws cloudformation describe-stacks --stack-name $(VPC_STACK_NAME) \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "BastionSecurityGroup") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export ECR_REPOSITORY_URI="`aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} \
				| jq -r '.repositories[0].repositoryUri'`  >> $(PROPERTIES_FILE)
	@echo "export COMMIT_HASH="`git log -1 --pretty=format:'%H' | cut -c 1-7` >> $(PROPERTIES_FILE)
	@echo "export CONTAINER_IMAGE_URL="`if [ -n "$(ECR_REPOSITORY_URI)" ] && [ -n "$(COMMIT_HASH)" ]; \
				then echo $(ECR_REPOSITORY_URI):$(COMMIT_HASH); else echo nginx; fi` >> $(PROPERTIES_FILE)
	@echo "export USER_POOL_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "UserPoolId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export APP_CLIENT_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "UserPoolClientId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@echo "export IDENTITY_POOL_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "IdentityPoolId") | .OutputValue'` >> $(PROPERTIES_FILE)
	@cat $(PROPERTIES_FILE)

init:
	../config/configure.sh

dump:
	@echo Parameters:
	@cat $(PROPERTIES_FILE)

config-db-secret:
	$(eval DB_PASSWORD = $(shell aws secretsmanager get-secret-value --secret-id ${DB_SECRET_NAME} \
					| jq -r '.SecretString' | jq -r '.password'))

getcommit:
	# Gets the 7-char Git commit hash.
	@# NOTE: if calling from AWS CodeCommit, this is in \$CODEBUILD_RESOLVED_SOURCE_VERSION variable
	$(eval COMMIT_HASH=$(shell git log -1 --pretty=format:"%H" | cut -c 1-7))
	@echo COMMIT_HASH=$(COMMIT_HASH)
