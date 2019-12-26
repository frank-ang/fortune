# Pipeline 
-include ../config/properties.mk ../config/properties.mk.gitignore

# EDIT ME
USERNAME=user01
EMAIL=frankang+user01@amazon.com
# TODO autogenerate random password.
PASSWORD=supersecret123.
.DEFAULT_GOAL := help

help:
	@echo "make [ validate | deploy | create-test-user ]"

validate:
	aws cloudformation validate-template --template-body file://cognito.yaml

deploy:
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./cognito.yaml \
      --stack-name ${AUTH_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

create-test-user: _create-test-user _confirm-test-user _get-test-user
	@echo "Test user ready for use: $(USERNAME)"
	# TODO use randomized creds and set into param store.

_create-test-user:
	@echo "Creating test user $(USERNAME) ..."
	aws cognito-idp sign-up \
		--client-id $(APP_CLIENT_ID) \
		--username $(USERNAME) \
		--password $(PASSWORD) \
		--user-attributes "Name=name,Value=$(USERNAME)" "Name=email,Value=$(EMAIL)"
	@sleep 1

_confirm-test-user:
	@echo "Confirming test user $(USERNAME) ..."
	aws cognito-idp admin-confirm-sign-up \
		--user-pool-id $(USER_POOL_ID) \
		--username $(USERNAME)
	@sleep 1

_get-test-user:
	@echo "Details of test user $(USERNAME) ..."
	aws cognito-idp admin-get-user --user-pool-id $(USER_POOL_ID) --username $(USERNAME)

delete-test-user:
	aws cognito-idp admin-delete-user --user-pool-id $(USER_POOL_ID) --username $(USERNAME) 


