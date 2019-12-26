# Canary
-include ../config/properties.mk ../config/properties.mk.gitignore

export CANARY_ITERATIONS=525600 # minutes in a year
export TEST_ITERATIONS=6 # 1 minute
export DELAY_REQUEST_MS=10000 # 10 secs
export CANARY_CONTAINER_NAME=fortune-canary

.DEFAULT_GOAL := help

help:
	@echo "make [ init | build | test | create-repo | push | deploy ]"

test-local:
	./run-test.sh

build: getcommit
	docker build -t $(CANARY_CONTAINER_NAME):$(COMMIT_HASH) \
				 -t $(CANARY_CONTAINER_NAME):latest .

test: stop run stop

run:
	@echo running canary container...
	docker run -it \
	-e API_ENDPOINT=${API_ENDPOINT} \
	-e CANARY_ITERATIONS=2 \
	-e TEST_ITERATIONS=3 \
	-e DELAY_REQUEST_MS=1000 \
	-e METRIC_NAMESPACE=${CANARY_CONTAINER_NAME} \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
	-e AWS_DEFAULT_REGION=${AWS_REGION} \
	--name=$(CANARY_CONTAINER_NAME) "$(CANARY_CONTAINER_NAME):latest"

stop:
	-docker stop $(CANARY_CONTAINER_NAME)
	-docker rm $(CANARY_CONTAINER_NAME)

create-repo:
	@echo create ECR repository, we decouple the repo outside of CloudFormation.
	aws ecr create-repository --repository-name "${CANARY_CONTAINER_NAME}" --tags "Key=project,Value=${PROJECT_TAG}"

clean-repo:
	aws ecr delete-repository --repository-name "${CANARY_CONTAINER_NAME}"

push: getcommit get-canary-repo-uri
	@echo Pushing image to ECR repository, 
	`aws ecr get-login --no-include-email`
	docker tag ${CANARY_CONTAINER_NAME}:latest ${CANARY_REPOSITORY_URI}:latest
	docker tag ${CANARY_CONTAINER_NAME}:latest ${CANARY_REPOSITORY_URI}:${COMMIT_HASH}
	echo "pushing image to: ${CANARY_REPOSITORY_URI}:${COMMIT_HASH}"
	@docker push ${CANARY_REPOSITORY_URI}:latest
	@docker push ${CANARY_REPOSITORY_URI}:${COMMIT_HASH}

get-canary-repo-uri:
	$(eval CANARY_REPOSITORY_URI = $(shell aws ecr describe-repositories \
					--repository-names ${CANARY_CONTAINER_NAME}  \
					| jq -r '.repositories[0].repositoryUri'))
	echo "CANARY_REPOSITORY_URI=$(CANARY_REPOSITORY_URI)"

validate: 
	aws cloudformation validate-template --template-body file://canary-fargate.yaml

deploy: validate getcommit get-canary-repo-uri
	@echo deploys the fargate cluster service with an nginx container
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file ./canary-fargate.yaml \
      --parameter-overrides \
        "ServiceName=$(CANARY_CONTAINER_NAME)"\
        "VpcId=$(VPC_ID)" \
        "PublicSubnet1=$(PUBLIC_SUBNET1)" "PublicSubnet2=$(PUBLIC_SUBNET2)" \
        "PublicSecurityGroupId=$(DMZ_SECURITY_GROUP)"  \
		"ImageUrl=$(CANARY_REPOSITORY_URI):${COMMIT_HASH}" \
		"apiEndpoint=${API_ENDPOINT}" \
		"canaryIterations=${CANARY_ITERATIONS}" \
		"testIterations=${TEST_ITERATIONS}" \
		"delayRequestMs=${DELAY_REQUEST_MS}" \
		"metricNamespace=${CANARY_CONTAINER_NAME}" \
      --stack-name ${CANARY_CONTAINER_NAME} \
      --tags "project=${PROJECT_TAG}"
