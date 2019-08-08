# CloudFormation makefile
STACK_NAME=playground-vpc

validate:
	aws cloudformation validate-template --template-body file://vpc_sample.yaml

deploy:
	echo deploy started at `date`
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./vpc_sample.yaml  \
      --parameter-overrides "EnvironmentName=playground" \
      --stack-name ${STACK_NAME} \
      --tags "project=playground"
