# Builder stage
FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install

COPY . .
RUN yarn build

# Production stage
FROM node:20-alpine
WORKDIR /app

ENV NODE_ENV=production
COPY package.json yarn.lock ./
RUN yarn install --production

COPY --from=builder /app .

# Ensure uploads folder exists
RUN mkdir -p /app/public/uploads && chmod -R 777 /app/public/uploads

EXPOSE 1337
CMD ["yarn", "start"]
