#!/bin/bash

# Save logs

exec > /var/log/user-data.log 2>&1

# Wait for boot

sleep 30

# Update packages

apt update -y

# Install Docker + AWS CLI

apt install -y docker.io awscli

# Start Docker

systemctl start docker
systemctl enable docker

# Docker permission

usermod -aG docker ubuntu

# Wait for IAM credentials

sleep 20

# Login to ECR

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

# Pull image

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

# Remove old container

docker rm -f backend || true

# Run container

docker run -d 
--name backend 
-p 5000:5000 
--restart always 
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest
