#!make
# Make Aurora RDS MySQL
-include ../properties.mk ./properties.mk.gitignore

validate:
	aws cloudformation validate-template --template-body file://aurora-mysql-serverless.yaml

deploy: validate init dump
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./aurora-mysql-serverless.yaml \
      --parameter-overrides "DatabaseName=playground" \
        "VpcId=$(VPC_ID)" "VpcSecurityGroupId=$(DB_SECURITY_GROUP)" \
        "AZ1=$(AZ1)" "AZ2=$(AZ2)" "SUBNET1=$(PRIVATE_SUBNET1)" "SUBNET2=$(PRIVATE_SUBNET2)" \
      --stack-name ${DB_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

load:
	# Create database tables and load sample CSV data
	$(eval DB_SECRET_ID = $(shell aws cloudformation describe-stacks --stack-name ${DB_STACK_NAME} \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "Secret") | .OutputValue'))
	$(eval DB_PASSWORD  = $(shell aws secretsmanager get-secret-value --secret-id ${DB_SECRET_ID} \
					| jq -r '.SecretString' | jq -r '.password'))
	$(eval DB_HOST = `aws cloudformation describe-stacks --stack-name $(DB_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "Host") | .OutputValue'`)
	@echo "DB_HOST = ${DB_HOST}"
	scp ./quotes.ddl.sql ec2-user@${BASTION_IP}:/tmp
	scp ./quotes.csv ec2-user@${BASTION_IP}:/tmp
	ssh ec2-user@${BASTION_IP} "mysql -u root -p${DB_PASSWORD} -h ${DB_HOST} < /tmp/quotes.ddl.sql"

query:
	# Test querying the DB;
	