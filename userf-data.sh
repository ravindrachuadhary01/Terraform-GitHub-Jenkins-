#!/bin/bash

# Logs
exec > /var/log/user-data.log 2>&1

# Update
apt update -y

# Install Docker
apt install docker.io -y

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

# Install AWS CLI
apt install awscli -y

# Wait a little
sleep 20

# Login to ECR
aws ecr get-login-password --region ap-south-1 | \
docker login \
--username AWS \
--password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

# Pull Image
docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

# Remove old container if exists
docker rm -f react-app || true

# Run Container
docker run -d \
--name react-app \
-p 80:80 \
--restart always \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

