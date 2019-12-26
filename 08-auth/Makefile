# Pipeline 
-include ../config/properties.mk ../config/properties.mk.gitignore

# EDIT ME
EMAIL=frankang+changeme@amazon.com
USERNAME=user01
TEMP_PASSWORD=changeme123.
PASSWORD=supersecret123.

.DEFAULT_GOAL := help

help:
	@echo "make [ validate | deploy ]"

validate:
	aws cloudformation validate-template --template-body file://cognito.yaml

deploy:
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./cognito.yaml \
      --stack-name ${AUTH_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

tmp-init:
	@echo "export USER_POOL_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "UserPoolId") | .OutputValue'`
	@echo "export APP_CLIENT_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "UserPoolClientId") | .OutputValue'`
	@echo "export IDENTITY_POOL_ID="`aws cloudformation describe-stacks --stack-name $(AUTH_STACK_NAME) \
			| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "IdentityPoolId") | .OutputValue'`

create-test-user: tmp-init
	@echo "creating test user $(USERNAME)"
	aws cognito-idp admin-create-user admin-create-user --user-pool-id $(USER_POOL_ID) \
    	--username $(USERNAME) --user-attributes "Name=name,Value=$(USERNAME)" "Name=email_verified,Value=True" \
		--temporary-password "$(TEMP_PASSWORD)" \
    @sleep 5
#@echo "created user" TODO fixme!


