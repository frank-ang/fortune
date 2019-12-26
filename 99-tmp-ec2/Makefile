# Makefile for EC2 AutoScaling group
-include ../config/properties.mk ../config/properties.mk.gitignore
LATEST_ALINUX_AMI:=`aws ssm get-parameters \
				--names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
				| jq -r '.Parameters[0].Value'`
EC2_INSTANCE_NAME:=${PROJECT_TAG}-standalone
.DEFAULT_GOAL := help
EC2_IAM_INSTANCE_PROFILE_NAME:=${PROJECT_TAG}-ec2-instance-profile
TEMPLATE_FILE := ec2.yaml
EC2_STACK_NAME := ${PROJECT_TAG}-ec2

help:
	@echo makes EC2 AutoScaling group with fortune app.
	@echo "make [init | deploy]"

run-instances:
	# deprecated.
	@echo "LATEST_ALINUX_AMI: ${LATEST_ALINUX_AMI}"

	aws ec2 run-instances --image-id $(LATEST_ALINUX_AMI) \
		--instance-type t3.nano \
		--key-name ${KEY_PAIR} \
		--subnet-id ${PUBLIC_SUBNET1} \
		--tag-specifications "ResourceType=instance,Tags=[{Key=project,Value=${PROJECT_TAG}},{Key=Name,Value=${EC2_INSTANCE_NAME}}]" \
		--iam-instance-profile Name=${EC2_IAM_INSTANCE_PROFILE_NAME} \
		--security-group-ids ${BASTION_SECURITY_GROUP} 

get-instance-id:
	$(eval RETVAL = $(shell \
		aws ec2 describe-instances --filter "Name=tag:Name,Values=fortune-standalone" \
		| jq -r '.Reservations[].Instances[] | .InstanceId + " " + .PublicIpAddress'))
	$(eval EC2_INSTANCE_ID = $(shell echo ${RETVAL} | cut -f1 -d' '))
	$(eval EC2_PUBLIC_IP = $(shell echo ${RETVAL} | cut -f2 -d' '))
	@echo EC2_INSTANCE_ID=${EC2_INSTANCE_ID}
	@echo EC2_PUBLIC_IP=${EC2_PUBLIC_IP}

# Install Cloudwatch agent (using SSM)
# Make Cloudwatch agent config file (using SSH console)
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

validate: 
	aws cloudformation validate-template --template-body file://${TEMPLATE_FILE}
	cfn-lint ${TEMPLATE_FILE}

deploy: validate
	aws cloudformation deploy --capabilities CAPABILITY_NAMED_IAM \
      --template-file ./${TEMPLATE_FILE}  \
      --parameter-overrides "KeyName=${KEY_PAIR}" "InstanceType=t3.nano" \
        "InstanceAMI=${LATEST_ALINUX_AMI}" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)" "PrivateSecurityGroupId=$(APP_SECURITY_GROUP)" \
        "VpcId=${VPC_ID}" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PrivateSubnet1=$(PRIVATE_SUBNET1)" "PrivateSubnet2=$(PRIVATE_SUBNET2)" \
      --stack-name ${EC2_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

clean: 
	aws cloudformation delete-stack --stack-name ${EC2_STACK_NAME}
