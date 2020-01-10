# quotes application 
-include ../config/properties.mk
.PHONY: dist
.DEFAULT_GOAL := help
help:
	@echo deploys the fortune web application
	@echo "make [ validate | init | deploy | upload ]"

validate: 
	aws cloudformation validate-template --template-body file://edge.yaml

deploy:
	@echo deploying edge cloudformation stack: ${EDGE_STACK_NAME} with bucket ${EDGE_BUCKET_NAME}
	aws cloudformation deploy --capabilities CAPABILITY_IAM \
      --template-file edge.yaml \
      --parameter-overrides \
        "BucketName=$(EDGE_BUCKET_NAME)"\
      --stack-name ${EDGE_STACK_NAME} \
      --tags "project=${PROJECT_TAG}"

dist:
	mkdir -p ./dist
	rm -rf ./dist/*
	cp -r ./src/ ./dist/
	@echo "Editing endpoint URL into web page..."
	sed -e "s|\(var fortuneEndpoint=\).*|\1'$(API_ENDPOINT_TEST)'|g" -i tmp ./dist/index.html
	rm ./dist/index.htmltmp

upload: dist
	@echo "Uploading dist files to s3 location: ${API_ENDPOINT}"
	aws s3 sync dist s3://$(EDGE_BUCKET_NAME)/ \
		--acl private --content-type text/html
