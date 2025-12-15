#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io awscli

systemctl start docker
systemctl enable docker

# Login to ECR using access key
aws configure set aws_access_key_id ${aws_key}
aws configure set aws_secret_access_key ${aws_secret}
aws configure set default.region ${region}

aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${ecr_repo}

# Pull image
docker pull ${ecr_repo}:${tag}

# Run Strapi PostgreSQL (external RDS)
docker run -d --name strapi-app \
  -p 80:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${db_host} \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=${db_name} \
  -e DATABASE_USERNAME=${db_user} \
  -e DATABASE_PASSWORD=${db_pass} \
  -e NODE_ENV=production \
  ${ecr_repo}:${tag}
