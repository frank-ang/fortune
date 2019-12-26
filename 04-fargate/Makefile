# Makefile for Fargate container cluster
-include ../config/properties.mk ../config/properties.mk.gitignore
.DEFAULT_GOAL := help

help:
	@echo "creates the Fargate cluster resource"
	@echo "make [ validate | init | deploy | create-repo | clean-repo ]"

validate: 
	aws cloudformation validate-template --template-body file://fargate.yaml

deploy: validate
	@echo deploys the fargate cluster service with an nginx container
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./fargate.yaml \
      --parameter-overrides \
        "ServiceName=$(CONTAINER_NAME)"\
        "VpcId=$(VPC_ID)" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PrivateSubnet1=$(PRIVATE_SUBNET1)" "PrivateSubnet2=$(PRIVATE_SUBNET2)" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)" "PrivateSecurityGroupId=$(APP_SECURITY_GROUP)" \
        "DbEndpointParameterName=$(DB_ENDPOINT_PARAMETER_NAME)" "DbSecretName=$(DB_SECRET_NAME)" \
        "ImageUrl=${CONTAINER_IMAGE_URL}" \
      --stack-name ${CONTAINER_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

create-repo:
	@echo deploy an empty ECR repository, we decouple the repo outside of CloudFormation.
	aws ecr create-repository --repository-name "${ECR_REPOSITORY_NAME}" --tags "Key=project,Value=${PROJECT_TAG}"

clean-repo:
	aws ecr delete-repository --repository-name "${ECR_REPOSITORY_NAME}"
