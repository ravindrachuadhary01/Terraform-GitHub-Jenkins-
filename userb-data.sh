#!/bin/bash

exec > /var/log/user-data.log 2>&1

apt update -y
apt install docker.io awscli -y

systemctl start docker
systemctl enable docker

sleep 20

aws ecr get-login-password --region ap-south-1 | \
docker login \
--username AWS \
--password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest

docker rm -f backend || true

docker run -d \
--name backend \
-p 5000:5000 \
--restart always \
192902842773.dkr.ecr.ap-south-1.amazonaws.com/flask-backend:latest