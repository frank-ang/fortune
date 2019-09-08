# Yet Another Demo App ("YADA")

> TODO rename project to "fortune"

The real purpose is to illustrate and communicate DevOps implementations of Infrastructure as Code, CI/CD.

Setup basic scaffolding. 

** Work in progress. **



## Infrastructure Setup

### Prereqs

* Use a shell environment, such as MacOS, Bash for Windows, or AWS Cloud9.
* Install ```jq```, ```aws cli```, ```make```.
* Configure ```properties.mk``` with your desired parameters.

### 1. VPC Network

Deploy Cloudformation stack to create a VPC (Virtual Private Cloud), that has:
* 2 public Subnets, 
* 2 private Subnets, 
* 1 NAT Gateway, 
* 4 Security Groups for Bastion, DMZ, Application, and Database

```
cd 01-vpc
make validate && make deploy
```

### 2. Bastion Host

Create 1 Bastion EC2 host into a public subnet, Bastion security group. Amazon Linux configured with SSM and CloudWatch agent.

```
cd ../02-bastion
make validate && make deploy
```

### 3. RDS Database 

1. Create an RDS Aurora MySQL serverless cluster inside a private subnet. 
```make init``` is required to initialize confiugration parameters.

```
cd ../03-database
make validate 
make init
make deploy
```

Please wait for the RDS MySQL database creation to complete, before proceeding to load data.

2. Load sample data. Again, call ```make init``` again to init parameters, such as the endpoint of the newly-created database.

```
make init
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

### 4. Container Cluster

Deploy Fargate cluster and sample app.

```
cd ../04-fargate
make validate
make init
make deploy
```

What this creates: 
* ECS cluster, 
* Load Balancer, 
* Fargate service that runs a sample Nginx image

>Verify the sample Nginx home page:
>Get the public load balancer DNS endpoint (see stack output). 
>Open in a browser to view the Nginx sample web page.  

### 5. Quotes Application.

Build the fortune application image. Publish to ECR.

1. Start Docker desktop. Build docker image.

```
cd ../05-quotes
make clean
make build
make run
make stop
```

What this does: 
* 

### 6. Quotes Application Pipeline.

```
cd ../06-pipeline
make verify
make deploy
```

Creates:
* standalone ECR repository
* CodePipeline stack

## TODOs

* Secrets Manager credentials requires Lambda function for cred rotation.

#### Systems Manager section below (please ignore)

TODO section to potentially use EC2 SSM instead of SSH. E.g. for populating sample data. Please ignore, for now.

```
# Run a command via SSM
aws ssm send-command --instance-ids ${EC2_INSTANCE} --document-name "AWS-RunShellScript" --comment "IP config" --parameters commands=ifconfig --output text

# Run a script via SSM (TODO)
aws ssm send-command --instance-ids ${EC2_INSTANCE} --document-name "AWS-RunRemoteScript" '--comment "remote script" --parameters sourceType= sourceInfo='{"path":"https://s3.amazonaws.com/path_to_script"}'
 commandLine="pythonMainFile.py argument1 argument2"
```
