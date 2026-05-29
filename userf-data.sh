#!/bin/bash
set -ex
exec > /var/log/user-data.log 2>&1

apt update -y
apt install -y docker.io awscli

systemctl enable docker
systemctl start docker

sudo usermod -aG docker $USER

# wait for docker
until systemctl is-active --quiet docker; do
  sleep 2
done

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 192902842773.dkr.ecr.ap-south-1.amazonaws.com

docker rm -f frontend || true

docker pull 192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest

docker run -d --restart always \
  --name frontend \
  -p 8080:80 \
  192902842773.dkr.ecr.ap-south-1.amazonaws.com/frontend-repo:latest