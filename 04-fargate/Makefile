# Makefile for Fargate container cluster
-include ../config/properties.mk ../config/properties.mk.gitignore
SERVICE_NAME=quotes
.DEFAULT_GOAL := help

help:
	@echo "make validate init deploy"

validate: 
	aws cloudformation validate-template --template-body file://fargate.yaml

deploy: validate
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./fargate.yaml \
      --parameter-overrides \
        "ServiceName=$(SERVICE_NAME)"\
        "VpcId=$(VPC_ID)" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PrivateSubnet1=$(PRIVATE_SUBNET1)" "PrivateSubnet2=$(PRIVATE_SUBNET2)" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)" "PrivateSecurityGroupId=$(APP_SECURITY_GROUP)" \
      --stack-name ${CONTAINER_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"