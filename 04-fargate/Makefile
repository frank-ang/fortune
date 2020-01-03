#!make
# Fargate cluster and service
-include ../config/properties.mk

.DEFAULT_GOAL := help

help:
	@echo "Creates the Fargate cluster resource"
	@echo "make [ validate | init | deploy | create-repo | "
	@echo "       delete | delete-repo ]"

validate: 
	aws cloudformation validate-template --template-body file://fargate.yaml

# TODO redeploy update is broken. FIX: set CONTAINER_IMAGE_URL correctly if nginx.
deploy: validate
	@echo Deploy the fargate cluster service
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
	@echo Deploy an empty ECR repository
	aws ecr create-repository --repository-name "${ECR_REPOSITORY_NAME}" --tags "Key=project,Value=${PROJECT_TAG}"

delete-repo:
	@echo "Remember to first delete images (manually on AWS Console)."
	# TODO aws ecr batch-delete-image
	aws ecr delete-repository --repository-name "${ECR_REPOSITORY_NAME}"

delete:
	# TODO delete task definitions? 
	aws cloudformation delete-stack --stack-name "$(CONTAINER_STACK_NAME)"
	aws cloudformation wait stack-delete-complete --stack-name "$(CONTAINER_STACK_NAME)"

