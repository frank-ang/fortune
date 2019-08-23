# Makefile for Fargate container cluster
-include ../config/properties.mk ../config/properties.mk.gitignore
.DEFAULT_GOAL := help

help:
	@echo "make validate init deploy create-ecr update"

validate: 
	aws cloudformation validate-template --template-body file://fargate.yaml

deploy: 
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./fargate.yaml \
      --parameter-overrides \
        "ServiceName=$(CONTAINER_NAME)"\
        "VpcId=$(VPC_ID)" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PrivateSubnet1=$(PRIVATE_SUBNET1)" "PrivateSubnet2=$(PRIVATE_SUBNET2)" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)" "PrivateSecurityGroupId=$(APP_SECURITY_GROUP)" \
        "ImageUrl=nginx" \
      --stack-name ${CONTAINER_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

create-ecr:
	@echo creating ECR repo ${ECR_REPOSITORY_NAME}
	-aws ecr create-repository --repository-name ${ECR_REPOSITORY_NAME}

update:
	$(eval LATEST_TAG := $(shell aws ecr describe-images --repository-name ${ECR_REPOSITORY_NAME} \
		--query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq -r '.'))
	$(eval REPO_BASE_URI := $(shell aws ecr describe-repositories --repository-names ${ECR_REPOSITORY_NAME} | \
		jq -r ".repositories[0].repositoryUri" ))
	@echo updating stack ${CONTAINER_STACK_NAME} with latest ImageUrl ${REPO_BASE_URI}:${LATEST_TAG}
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./fargate.yaml \
      --parameter-overrides \
        "ImageUrl=${REPO_BASE_URI}:${LATEST_TAG}" \
        "DbEndpointParameterName=${DB_ENDPOINT_PARAMETER_NAME}" \
        "DbSecretName=${DB_SECRET_NAME}" \
      --stack-name ${CONTAINER_STACK_NAME} \
