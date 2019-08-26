# quotes application 
-include ../config/properties.mk ../config/properties.mk.gitignore
# EDIT ME.
LOCAL_REPOSITORY=golang-fortune
DOCKER_HUB_REPOSITORY=frankang/golang-quotes

.DEFAULT_GOAL := help
help:
	@echo make clean build stop test push
	@echo optionally, make db-tunnel
	@echo go clean
	@echo make db-tunnel
	@echo ./fortune

build: getcommit
	go build
	docker build -t $(LOCAL_REPOSITORY):$(COMMIT_HASH) -t $(LOCAL_REPOSITORY):latest .

test: run stop

run:
	@echo run docker container with environment variables.
	@# Set AWS_DEFAULT_REGION to your region.
	docker run -d -p 80:80 \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_REGION=${AWS_REGION} \
	-e DB_ENDPOINT_PARAMETER_NAME=${DB_ENDPOINT_PARAMETER_NAME} \
	-e DB_SECRET_NAME=${DB_SECRET_NAME} \
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

push: getcommit
	# Shortcut for pushing to ECR directly to private ECR repository, 
	# convenience for bypassing pipeline, but bypasses pipeline governance.
	# The private ECR registry is now being defined in the pipeline instead.  
	`aws ecr get-login --no-include-email`
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	echo "pushing image to: ${ECR_REPOSITORY_URI}:${COMMIT_HASH}"
	@docker push ${ECR_REPOSITORY_URI}:latest
	@docker push ${ECR_REPOSITORY_URI}:${COMMIT_HASH}

push-dockerhub: getcommit
	# Push the image to your public Docker Hub registry 
	# First, ensure you have previously ```docker login``` on CLI console.
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:${COMMIT_HASH}
	docker push ${DOCKER_HUB_REPOSITORY}:latest
	docker push $(DOCKER_HUB_REPOSITORY):${COMMIT_HASH}

db-tunnel: config-db-secret
	@echo Starting tunnel into mysql via bastion. 
	@# convenience for local development against remote Aurora.
	ssh ec2-user@${BASTION_IP} -L 3306:${DB_HOST}:3306 -fN
	@echo Verifying connection to local tunnel ...
	@mysql -u root -p${DB_PASSWORD} -h 127.0.0.1 -e "show databases"

update-stack: getcommit
	@echo updating cloudformation stack: ${CONTAINER_STACK_NAME}, with image: $(ECR_REPOSITORY_URI):${COMMIT_HASH}
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ../04-fargate/fargate.yaml \
      --parameter-overrides \
        "ServiceName=$(CONTAINER_NAME)"\
        "VpcId=$(VPC_ID)" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PrivateSubnet1=$(PRIVATE_SUBNET1)" "PrivateSubnet2=$(PRIVATE_SUBNET2)" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)" "PrivateSecurityGroupId=$(APP_SECURITY_GROUP)" \
        "ImageUrl=$(ECR_REPOSITORY_URI):${COMMIT_HASH}" \
        "DbEndpointParameterName=${DB_ENDPOINT_PARAMETER_NAME}" "DbSecretName=${DB_SECRET_NAME}"\
      --stack-name ${CONTAINER_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

deploy-web:
	@echo deploying edge cloudformation stack: ${EDGE_STACK_NAME} with bucket ${EDGE_BUCKET_NAME}
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file public/edge.yaml \
      --parameter-overrides \
        "BucketName=$(EDGE_BUCKET_NAME)"\
      --stack-name ${EDGE_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

upload-web:
	$(eval API_ENDPOINT = $(shell aws cloudformation describe-stacks --stack-name $(CONTAINER_STACK_NAME) \
				| jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "PublicLoadBalancerDNSName") | .OutputValue'))
	@echo updating web page endpoint URL : http://${API_ENDPOINT}/fortune
	sed "s/\(var fortuneUrl=\).*/\1'http:\/\/$(API_ENDPOINT)\/fortune'/" public/index.html > public/index.html.gitignore
	@echo uploading web page to s3 : ${API_ENDPOINT}/fortune
	aws s3 cp public/index.html.gitignore s3://$(EDGE_BUCKET_NAME)/index.html --acl public-read --content-type text/html
	aws s3 cp public/raised-blockquote.css s3://$(EDGE_BUCKET_NAME)/ --acl public-read --content-type text/css
