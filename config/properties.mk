# shared Makefile parameters and functions for include
include ../config/config.env
-include ../config/config.env.gitignore

init:
	../config/configure.sh

dump:
	@echo Parameters:
	@cat $(PROPERTIES_FILE)

config-db-secret:
	$(eval DB_PASSWORD = $(shell aws secretsmanager get-secret-value --secret-id ${DB_SECRET_NAME} \
					| jq -r '.SecretString' | jq -r '.password'))

getcommit:
	# Gets the 7-char Git commit hash.
	@# NOTE: if calling from AWS CodeCommit, this is in \$CODEBUILD_RESOLVED_SOURCE_VERSION variable
	$(eval COMMIT_HASH=$(shell git log -1 --pretty=format:"%H" | cut -c 1-7))
	@echo COMMIT_HASH=$(COMMIT_HASH)
