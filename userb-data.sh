#!/bin/bash

# Logs

exec > /var/log/user-data.log 2>&1

# Update

apt update -y

# Install Docker

apt install docker.io -y

systemctl start docker
systemctl enable docker

# Install AWS CLI

apt install awscli -y

# Wait a little for IAM Role

sleep 20

# Login to ECR

aws ecr get-login-password --region ap-south-1 | 
docker login 
--username AWS 
--password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

# Pull Backend Image

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

# Remove old container if exists

docker rm -f backend || true

# Run Backend Container

docker run -d 
--name backend 
-p 5000:5000 
--restart always 
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest
