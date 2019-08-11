# quotes application 
NAME=quotes
LOCAL_REPOSITORY=golang-quotes
DOCKER_HUB_REPOSITORY=frankang/golang-quotes
AWS_DEFAULT_REGION=ap-southeast-1
ECR_REPOSITORY=playground-container

help:
	@#echo make clean build run stop 

build: getcommit build-local
	docker build -t $(LOCAL_REPOSITORY):$(COMMIT_HASH) -t $(LOCAL_REPOSITORY):latest .

build-local:
	go build -o hello-local

test: run stop

run:
	# Run docker container with AWS environment variables.
	# Change AWS_DEFAULT_REGION to your region.
	docker run -d -p 80:80 \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	--name=$(NAME) "$(LOCAL_REPOSITORY):latest"
	curl localhost:80

stop:
	-docker stop $(NAME)
	-docker rm $(NAME)

clean: stop
	go clean

getcommit:
	# Sets the 7-char Git commit hash.
	@# TODO, If using AWS CodeCommit, should set from \$CODEBUILD_RESOLVED_SOURCE_VERSION variable
	$(eval COMMIT_HASH=$(shell git log -1 --pretty=format:"%H" | cut -c 1-7))
	@echo COMMIT_HASH=$(COMMIT_HASH)

push-private: getcommit
	# THIS IS DEPRECATED. 
	# Used for pushing to ECR directly from local dev desktop, bypassing pipeline.
	# Push the image to the private ECR registry
	# The private ECR registry is now being defined in the pipeline instead.  
	`aws ecr get-login --no-include-email`
	@# aws ecr list-images --repository-name="${CONTAINER_STACK_NAME}"
	$(eval ECR_REPOSITORY_URI = $(shell aws ecr describe-repositories --repository-names ${ECR_REPOSITORY} \
				| jq -r '.repositories[0].repositoryUri'))
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	echo "pushing image to ECR_REPOSITORY_URI=${ECR_REPOSITORY_URI}"
	@docker push ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	@docker push ${ECR_REPOSITORY_URI}:latest

push-public: getcommit
	# Push the image to your public Docker Hub registry 
	# First, ensure you have previously ```docker login``` on CLI console.
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:${COMMIT_HASH}
	docker push ${DOCKER_HUB_REPOSITORY}:latest
	docker push $(DOCKER_HUB_REPOSITORY):${COMMIT_HASH}
