# quotes application 
-include ../config/properties.mk ../config/properties.mk.gitignore

LOCAL_REPOSITORY=golang-fortune
DOCKER_HUB_REPOSITORY=frankang/golang-quotes

.DEFAULT_GOAL := help
help:
	@echo builds and deploys the fortune application to a registry
	@echo "make [ clean | build | test | push | update-stack ]"

build: getcommit
	go build
	docker build -t $(LOCAL_REPOSITORY):$(COMMIT_HASH) -t $(LOCAL_REPOSITORY):latest .

test: db-tunnel run stop

run:
	@echo run docker container locally with environment variables.
	@echo requires local host mysql or local host tunnel to remote mysql.
	@echo access host via "host.docker.internal" which works on Docker for Mac and Windows. Not tested on Docker Linux
	docker run -d -p 80:80 \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_REGION=${AWS_REGION} \
	-e DB_HOST="host.docker.internal" \
	-e DB_SECRET_NAME=${DB_SECRET_NAME} \
	--name=$(CONTAINER_NAME) "$(LOCAL_REPOSITORY):latest"
	# -e DB_ENDPOINT_PARAMETER_NAME=${DB_ENDPOINT_PARAMETER_NAME} # ignored if DB_HOST exists
	curl localhost:80
	curl localhost:80/fortune

stop:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

clean: stop
	go clean

push: getcommit
	@echo Pushing image to ECR repository, 
	`aws ecr get-login --no-include-email`
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${ECR_REPOSITORY_URI}:${COMMIT_HASH}
	echo "pushing image to: ${ECR_REPOSITORY_URI}:${COMMIT_HASH}"
	@docker push ${ECR_REPOSITORY_URI}:latest
	@docker push ${ECR_REPOSITORY_URI}:${COMMIT_HASH}

push-dockerhub: getcommit
	@echo Pushing the image to your public Docker Hub registry...
	# First, ensure you have previously ```docker login``` on CLI console.
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:latest
	docker tag ${LOCAL_REPOSITORY}:latest ${DOCKER_HUB_REPOSITORY}:${COMMIT_HASH}
	docker push ${DOCKER_HUB_REPOSITORY}:latest
	docker push $(DOCKER_HUB_REPOSITORY):${COMMIT_HASH}

db-tunnel: config-db-secret
	@echo Starting local tunnel into remote mysql via bastion. 
	@echo This is a convenience for local development against remote Aurora.
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
