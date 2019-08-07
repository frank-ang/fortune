# Sample deployments. 

## Bastion Host

Cloudformation template for a standalone bastion EC2 host, using Amazon Linux enabled with SSM (default) and CloudWatch agent.

To create/update the stack:
```
aws cloudformation deploy --capabilities CAPABILITY_IAM --template-file ./BastionHost.yaml  --parameter-overrides "VPC=REPLACE_ME" "AZ=us-east-1a" "KeyPair=REPLACE_ME" --stack-name REPLACE_ME
```

## Quotes.
Source quotes data ownloaded from:
https://raw.githubusercontent.com/akhiltak/inspirational-quotes/master/Quotes.csv
