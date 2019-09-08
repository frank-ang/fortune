# quotes application 
-include ../config/properties.mk ../config/properties.mk.gitignore

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

upload:
	@echo editing endpoint URL into web page : http://${API_ENDPOINT}/fortune
	sed "s/\(var fortuneUrl=\).*/\1'http:\/\/$(API_ENDPOINT)\/fortune'/" ./index.html > ./index.html.gitignore
	@echo uploading web page to s3 location: ${API_ENDPOINT}
	aws s3 cp ./index.html.gitignore s3://$(EDGE_BUCKET_NAME)/index.html --acl private --content-type text/html
	aws s3 cp ./raised-blockquote.css s3://$(EDGE_BUCKET_NAME)/ --acl private --content-type text/css
