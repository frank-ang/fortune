# Yet Another Sample App. 

Yet another application. Sample API, 

The real purpose is to illustrate and communicate DevOps implementations of Infrastructure as Code, CI/CD.

Setup basic scaffolding first. Work in progress, not too interesting for now.



## Infrastructure

### Prereqs

* Install ```jq```, ```aws cli```, ```make```.
* Setup AWS environment console variables.

### VPC

Deploy Cloudformation stack to create a 2-AZ VPC, public subnets, private subnets, NAT gateway, and security groups.

```
cd vpc
make validate && make deploy
```

### Bastion Host

Create bastion ALinux EC2 host into VPC with SSM and CloudWatch agent.

```
cd bastion
make validate && make deploy
```

### Database 

Create Aurora serverless into the VPC

```
cd database
make validate && make deploy
```

Sample quotes from: https://raw.githubusercontent.com/akhiltak/inspirational-quotes/master/Quotes.csv
