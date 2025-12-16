#!/bin/bash
set -e

yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /home/ec2-user/strapi
cd /home/ec2-user/strapi

cat <<EOF > .env
HOST=0.0.0.0
PORT=1337
NODE_ENV=production

APP_KEYS=${app_keys}
API_TOKEN_SALT=${api_token_salt}
ADMIN_JWT_SECRET=${admin_jwt_secret}
EOF

docker pull ${image_name}:${image_tag}

docker rm -f strapi || true

docker run -d \
  --name strapi \
  --env-file /home/ec2-user/strapi/.env \
  -p 1337:1337 \
  --restart unless-stopped \
  ${image_name}:${image_tag}
