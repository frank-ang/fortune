# quotes application 
-include ../config/properties.mk ../config/properties.mk.gitignore
.DEFAULT_GOAL := help

CONTAINER_NAME=quotes
LOCAL_REPOSITORY=golang-quotes
DOCKER_HUB_REPOSITORY=frankang/golang-quotes
AWS_DEFAULT_REGION=ap-southeast-1
ECR_REPOSITORY=playground-container

help:
	@echo make clean build run stop 

build: getcommit build-local
	docker build -t $(LOCAL_REPOSITORY):$(COMMIT_HASH) -t $(LOCAL_REPOSITORY):latest .

build-local:
	go build -o ${CONTAINER_NAME}

test: run stop

run:
	@echo runs docker container with AWS environment variables.
	@# Set AWS_DEFAULT_REGION to your region.
	docker run -d -p 80:80 \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	--name=$(CONTAINER_NAME) "$(LOCAL_REPOSITORY):latest"
	curl localhost:80

stop:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

clean: stop
	go clean

getcommit:
	# Sets the 7-char Git commit hash.
	@# TODO, If using AWS CodeCommit, should set from \$CODEBUILD_RESOLVED_SOURCE_VERSION variable
	$(eval COMMIT_HASH=$(shell git log -1 --pretty=format:"%H" | cut -c 1-7))
	@echo COMMIT_HASH=$(COMMIT_HASH)

push-ecr: getcommit
	# Shortcut for pushing to ECR directly to private ECR repository, 
	# convenience for bypassing pipeline, but bypasses pipeline governance.
	# The private ECR registry is now being defined in the pipeline instead.  
	`aws ecr get-login --no-include-email`
	$(eval ECR_REPOSITORY_URI = $(shell aws ecr describe-repositories --repository-names ${ECR_REPOSITORY} \
				| jq -r '.repositories[0].repositoryUri'))
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	echo "pushing image to ECR_REPOSITORY_URI=${ECR_REPOSITORY_URI}"
	@docker push ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	@docker push ${ECR_REPOSITORY_URI}:latest

push-dockerhub: getcommit
	# Push the image to your public Docker Hub registry 
	# First, ensure you have previously ```docker login``` on CLI console.
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:${COMMIT_HASH}
	docker push ${DOCKER_HUB_REPOSITORY}:latest
	docker push $(DOCKER_HUB_REPOSITORY):${COMMIT_HASH}

start-db-tunnel: config-db-secret
	@echo Starting tunnel into mysql via bastion. 
	@# convenience for local development against remote Aurora.
	ssh ec2-user@${BASTION_IP} -L 3306:${DB_HOST}:3306 -fN
	@echo Verifying connection to local tunnel ...
	mysql -u root -p${DB_PASSWORD} -h 127.0.0.1 -e "show databases"

