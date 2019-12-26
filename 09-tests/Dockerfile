FROM alpine:3.10

# Install dependencies
RUN apk add bash libxml2-utils
# Install aws-cli
RUN apk -Uuv add groff less python py-pip
RUN pip install --upgrade pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*
RUN apk add --update nodejs npm
RUN npm install -g newman newman-reporter-html

# Set the Current Working Directory
RUN mkdir -p /canary
WORKDIR /canary

# Copy Postman file
COPY ./fortune-tests.postman_collection.json .
COPY ./run-test.sh .
RUN chmod 755 ./run-test.sh

# Command to run
CMD ["/canary/run-test.sh"]
