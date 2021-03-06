#!make
# Authentication stack with Cognito UserPool 
-include ../config/properties.mk

# EDIT ME
USERNAME=user01
EMAIL=frankang+user01@amazon.com
# TODO autogenerate random password.
PASSWORD=supersecret123.
.DEFAULT_GOAL := help

help:
	@echo "make [ validate | deploy | create-test-user | test-auth | delete-test-user "
	@echo "       create-user-pool-domain | delete-user-pool-domain | config-app-client ]"

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
	aws cognito-idp admin-get-user \
		--user-pool-id $(USER_POOL_ID) \
		--username $(USERNAME)

test-auth:
	@# Authenticate as the demo user and retrieve the OAUTH ID Token, which is a JWT Bearer token. 
	aws cognito-idp initiate-auth --client-id $(APP_CLIENT_ID) \
		--auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$(USERNAME),PASSWORD=$(PASSWORD) \
		| jq -r ".AuthenticationResult.IdToken"
	@#curl -X GET -H "content-type: application/json" -H "Authorization: $(OAUTH_ID_TOKEN)" $(API_ENDPOINT)/fortune

delete-test-user:
	aws cognito-idp admin-delete-user \
		--user-pool-id $(USER_POOL_ID) \
		--username $(USERNAME) 

create-user-pool-domain:
	aws cognito-idp create-user-pool-domain \
		--user-pool-id $(USER_POOL_ID) \
		--domain $(COGNITO_DOMAIN_NAME)
	@sleep 1
	aws cognito-idp describe-user-pool-domain \
		--domain $(COGNITO_DOMAIN_NAME)

delete-user-pool-domain:
	aws cognito-idp delete-user-pool-domain \
		--user-pool-id $(USER_POOL_ID) \
		--domain $(COGNITO_DOMAIN_NAME)

config-app-client:
	aws cognito-idp update-user-pool-client \
		--user-pool-id  "$(USER_POOL_ID)" --client-id "$(APP_CLIENT_ID)" \
		--allowed-o-auth-flows-user-pool-client \
		--allowed-o-auth-flows "code" "implicit" \
		--allowed-o-auth-scopes "openid" \
		--callback-urls '["https://$(EDGE_DOMAIN_NAME)/", \
			"https://$(API_ENDPOINT)/oauth2/idpresponse", \
			"http://localhost:8080" ]' \
		--logout-urls '[ "http://localhost:8080" ]' \
		--explicit-auth-flows ALLOW_ADMIN_USER_PASSWORD_AUTH ALLOW_USER_PASSWORD_AUTH ALLOW_REFRESH_TOKEN_AUTH \
		--prevent-user-existence-errors "ENABLED" \
		--supported-identity-providers "COGNITO"


