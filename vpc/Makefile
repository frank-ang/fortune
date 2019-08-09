# VPC Creation Makefile
-include ../properties.mk

validate:
	# Validate the cloudformation template
	aws cloudformation validate-template --template-body file://vpc_sample.yaml

deploy:
	# Create the VPC
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./vpc_sample.yaml  \
      --parameter-overrides "EnvironmentName=playground" \
      --stack-name ${VPC_STACK_NAME} \
      --tags "project=playground"
