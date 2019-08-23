#!make
# Make Aurora RDS MySQL
-include ../config/properties.mk ../config/properties.mk.gitignore

.DEFAULT_GOAL := help
help:
	@echo deploys the Aurora RDS Database
	@echo make validate init deploy load test

validate:
	aws cloudformation validate-template --template-body file://aurora-mysql-serverless.yaml

deploy: validate init dump
	@echo deploying database...
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./aurora-mysql-serverless.yaml \
      @# TODO FIX Beta reference \
      --parameter-overrides "DatabaseName=${PROJECT_TAG}Beta" \
        "VpcId=$(VPC_ID)" "VpcSecurityGroupId=$(DB_SECURITY_GROUP)" \
        "AZ1=$(AZ1)" "AZ2=$(AZ2)" "SUBNET1=$(PRIVATE_SUBNET1)" "SUBNET2=$(PRIVATE_SUBNET2)" \
        "EndpointParameterName=${ENDPOINT_PARAMETER_NAME}" "SecretName=${SECRET_NAME}" \
      --stack-name ${DB_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

load: config-db-secret
	@echo Creating tables and load sample CSV data into database ...
	scp ./quotes.ddl.sql ec2-user@${BASTION_IP}:/tmp
	scp ./quotes.csv ec2-user@${BASTION_IP}:/tmp
	ssh ec2-user@${BASTION_IP} "mysql -u root -p${DB_PASSWORD} -h ${DB_HOST} < /tmp/quotes.ddl.sql"

test: config-db-secret
	# Test querying the DB;
	ssh ec2-user@${BASTION_IP} "mysql -u root -p${DB_PASSWORD} -h ${DB_HOST} -e 'use demo; select count(1) from quotes;'"
