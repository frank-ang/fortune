#!/bin/bash
# install codedeploy
yum -y update
yum install -y ruby
cd /home/ec2-user
curl -O https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto

