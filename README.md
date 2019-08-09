# Yet Another Demo App ("YADA")

The real purpose is to illustrate and communicate DevOps implementations of Infrastructure as Code, CI/CD.

Setup basic scaffolding. 

** Work in progress. **



## Infrastructure Setup

### Prereqs

* Use a shell environment, such as MacOS, Bash for Windows, or AWS Cloud9.
* Install ```jq```, ```aws cli```, ```make```.
* Configure ```properties.mk``` with your desired parameters.

### VPC Network

Deploy Cloudformation stack to create a VPC (Virtual Private Cloud), that has:
* 2 public Subnets, 
* 2 private Subnets, 
* 1 NAT Gateway, 
* 4 Security Groups for Bastion, DMZ, Application, and Database

```
cd vpc
make validate && make deploy
```

### Bastion Host

Create 1 Bastion EC2 host into a public subnet, Bastion security group. Amazon Linux configured with SSM and CloudWatch agent.

```
cd bastion
make validate
make deploy
```

### RDS Database 

1. Create an RDS Aurora MySQL serverless cluster inside a private subnet

```
cd database
make validate 
make init
make deploy
```

Please wait for the RDS MySQL database creation to complete, before proceeding to load data.

2. Load sample data

```
make load 
```
Accept any SSH prompts if its the first time connecting to the bastion host.

> Verify the following console output is returned, indicating the number of sample data rows created in the ```quotes``` table.
>
>```
>COUNT(1)
>75966
>```
>
>> Credits: Sample quotes sourced from [https://raw.githubusercontent.com/akhiltak/inspirational-quotes/master/Quotes.csv]

### Application

Deploy Fargate cluster and sample app.

```
cd fargate
make verify
make init
make deploy
```

>Get the public load balancer DNS name. Open in a browser to view a sample web page.  

....TODO!

## TODOs

#### Secrets Manager credentials rotation

#### Systems Manager section (please ignore)

TODO section for EC2 SSM instead of SSH. Please ignore.

```
# Run a command via SSM
aws ssm send-command --instance-ids ${EC2_INSTANCE} --document-name "AWS-RunShellScript" --comment "IP config" --parameters commands=ifconfig --output text

# Run a script via SSM (TODO)
aws ssm send-command --instance-ids ${EC2_INSTANCE} --document-name "AWS-RunRemoteScript" '--comment "remote script" --parameters sourceType= sourceInfo='{"path":"https://s3.amazonaws.com/path_to_script"}'
 commandLine="pythonMainFile.py argument1 argument2"
```
