# Pipeline 
-include ../properties.mk ./properties.mk ./properties.mk.gitignore
PIPELINE_STACK_NAME=playground-pipeline
REPOSITORY_NAME=playground-repo
GitHubRepo=DeployPlayground
GitHubBranch=dev-cicd
GitHubUser=frank-ang
Cluster := $(shell aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "ECSClusterName") | .OutputValue')
ServiceName:= $(shell aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "ServiceName") | .OutputValue')

.DEFAULT_GOAL := help

help:
	@echo make validate deploy

validate:
	aws cloudformation validate-template --template-body file://pipeline.yaml

deploy-ecr:
	-aws ecr create-repository --repository-name ${REPOSITORY_NAME}

deploy: validate deploy-ecr
	# prompt for github token.
	$(eval GitHubToken ?= $(shell bash -c 'read -s -p "GitHubToken: " GitHubToken; echo $$GitHubToken'))
	# create the pipeline
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./pipeline.yaml \
      --parameter-overrides \
		"GitHubRepo=${GitHubRepo}" "GitHubBranch=${GitHubBranch}" \
		"GitHubUser=${GitHubUser}" "GitHubToken=${GitHubToken}" \
		"Cluster=$(Cluster)" "ServiceName=$(ServiceName)" "Repository=${REPOSITORY_NAME}"\
      --stack-name ${PIPELINE_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"
