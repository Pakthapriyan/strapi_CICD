#!/bin/bash
set -e

# -------------------------
# Install Docker ONLY if not present
# -------------------------
if ! command -v docker &> /dev/null; then
  amazon-linux-extras install docker -y
  systemctl enable docker
  systemctl start docker
fi

# -------------------------
# Run Strapi
# -------------------------
docker rm -f strapi || true

docker pull ${image_name}:${image_tag}

docker run -d \
  --name strapi \
  -p 1337:1337 \
  -e HOST=0.0.0.0 \
  -e PORT=1337 \
  -e NODE_ENV=production \
  -e APP_KEYS=${app_keys} \
  -e API_TOKEN_SALT=${api_token_salt} \
  -e ADMIN_JWT_SECRET=${admin_jwt_secret} \
  --restart unless-stopped \
  ${image_name}:${image_tag}
