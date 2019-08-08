# Sample. 

Not sure what to make of this project yet. Setup basic scaffolding first.

## VPC

Deploy Cloudformation stack to create a 2-AZ VPC, public subnets, private subnets, NAT gateway, and security groups.

```
cd vpc
make validate && make deploy
```

## Bastion Host

Create bastion ALinux EC2 host into VPC with SSM and CloudWatch agent.

```
cd bastion
make validate && make deploy
```

## Database 

Create Aurora serverless into the VPC

```
cd database
TODO... create database into VPC
TODO... load sample data.
```

Sample quotes from: https://raw.githubusercontent.com/akhiltak/inspirational-quotes/master/Quotes.csv
