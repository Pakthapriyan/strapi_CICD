#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

docker network create strapi-net || true

# Run postgres container
docker run -d \
  --name strapi-postgres \
  --network strapi-net \
  -e POSTGRES_USER=${db_username} \
  -e POSTGRES_PASSWORD=${db_password} \
  -e POSTGRES_DB=${db_name} \
  -v /var/lib/strapi-postgres:/var/lib/postgresql/data \
  postgres:14

# Wait for DB
sleep 10

# Pull your image
docker pull ${docker_image}

# Start Strapi
docker run -d \
  --name strapi-app \
  --network strapi-net \
  -p 80:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=strapi-postgres \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=${db_name} \
  -e DATABASE_USERNAME=${db_username} \
  -e DATABASE_PASSWORD=${db_password} \
  ${docker_image}
