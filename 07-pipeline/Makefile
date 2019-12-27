#!make
# Deploy CodePipeline 
-include ../config/properties.mk

# EDIT ME
GitHubRepo=DeployPlayground
GitHubBranch=dev-cicd
GitHubUser=frank-ang
Cluster := $(shell aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "ECSClusterName") | .OutputValue')
ServiceName:= $(shell aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "ServiceName") | .OutputValue')

.DEFAULT_GOAL := help

help:
	@echo "make [ validate | deploy ]"

validate:
	aws cloudformation validate-template --template-body file://pipeline.yaml

deploy: validate
	@echo "Create CodePipeline stack..."
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./pipeline.yaml \
      --parameter-overrides \
		"GitHubRepo=${GitHubRepo}" "GitHubBranch=${GitHubBranch}" \
		"GitHubUser=${GitHubUser}" "GitHubToken=CHANGEME" \
		"Cluster=$(Cluster)" "ServiceName=$(ServiceName)" "Repository=${ECR_REPOSITORY_NAME}"\
      --stack-name ${PIPELINE_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
	@echo "CodePipeline stack created. Please post-configure the pipeline to your source repository."
