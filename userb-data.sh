#!/bin/bash

exec > /var/log/user-data.log 2>&1

echo "Starting setup..."

# Update system
apt update -y

# Install Docker
apt install -y docker.io

# Start Docker
systemctl start docker
systemctl enable docker

# Give docker permission (IMPORTANT FIX)
chmod 666 /var/run/docker.sock

# Install AWS CLI
apt install -y awscli

# Wait for services
sleep 30

echo "Logging into ECR..."

aws ecr get-login-password --region ap-south-1 | docker login \
--username AWS \
--password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

echo "Pulling image..."

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

echo "Stopping old container..."

docker rm -f backend || true

echo "Running backend container..."

docker run -d \
--name backend \
-p 5000:5000 \
--restart always \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

echo "Done!"