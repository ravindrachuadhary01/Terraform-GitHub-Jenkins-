#!/bin/bash

sudo apt update -y

sudo apt install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin \
192902842773.dkr.ecr.ap-south-1.amazonaws.com

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

docker run -d -p 5000:5000 \
--name flask-app \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest