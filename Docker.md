# Docker Deep Dive
## 1. Problem Docker Solves

Traditional deployment issues:

Works on my machine problem

Applications behave differently across environments.

Dependency conflicts

Different apps require different versions of libraries, runtimes, Python/Java versions, etc.

Heavy Virtual Machines

Each VM has a full OS

GBs in size

Slow boot time

High resource usage

How Docker Solves It

Packages app + dependencies together

Lightweight containers

Portable across environments

Fast deployment and scaling

## 2. Virtual Machines vs Docker
| Feature          | Virtual Machine     | Docker Container          |
| ---------------- | ------------------- | ------------------------- |
| Operating System | Full Guest OS       | Shares Host Kernel        |
| Size             | Large (GBs)         | Small (MBs)               |
| Boot Time        | Minutes             | Seconds                   |
| Performance      | Heavy               | Lightweight               |
| Isolation        | Strong              | Medium                    |
| Best For         | Running multiple OS | Microservices, deployment |

## 3. Docker Architecture
3.1 Docker Daemon (dockerd)

Background service

Handles container build/run/manage operations

3.2 Docker Client (docker CLI)

Commands like:

docker run
docker build
docker ps


Communicates with the Docker daemon.

3.3 Docker Images

Read-only templates

Built using Dockerfile

Basis for containers

3.4 Docker Containers

Running instances of images

Isolated environments

3.5 Docker Registry

Stores images (Docker Hub, ECR, GCR)

## 4. Dockerfile Deep Dive

Example Dockerfile:

FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]

Line-by-line Explanation
FROM node:18-alpine

Sets the base image.

WORKDIR /app

Defines the working directory inside the container.

COPY package*.json ./

Copies dependency files.

RUN npm install

Installs dependencies.

COPY . .

Copies source code.

EXPOSE 3000

Documents port used by the app.

CMD ["npm", "start"]

Default command executed when container starts.

Common Dockerfile Instructions
ADD

Copy files with additional features (extract tar, download from URL).

COPY

Simple copy from host to image (preferred over ADD).

ENV

Set environment variables.

ARG

Build-time variables.

ENTRYPOINT

Defines executable that always runs.

## 5. Key Docker Commands
Container Commands
docker run <image>
docker run -d --name app -p 8080:80 nginx
docker ps
docker ps -a
docker stop <id>
docker start <id>
docker restart <id>
docker rm <id>
docker rm -f <id>

Image Commands
docker images
docker pull <image>
docker rmi <image>
docker build -t myapp .

Logs and Debugging
docker logs <id>
docker logs -f <id>
docker exec -it <id> bash
docker inspect <id>
docker stats
docker top <id>

Cleanup
docker system prune -a
docker image prune

## 6. Docker Networking

Docker Networking controls communication between containers, host, and external systems.

Types of Docker Networks
1. Bridge Network (Default)

Containers communicate within the same host

Good for app + database setups

Example:

docker network create mynet
docker run --network=mynet nginx

2. Host Network

Container shares host network

No isolation, faster performance

docker run --network=host nginx

3. None Network

No networking

Fully isolated container

docker run --network=none ubuntu

4. Overlay Network

Multi-host networking

Used in Docker Swarm or Kubernetes setups

5. Macvlan Network

Each container gets its own MAC address

Appears as a separate machine on LAN

Useful for legacy systems or direct access networks

## 7. Docker Volumes and Persistence

Containers are temporary; data is lost unless persisted.

Types of Volumes
1. Anonymous Volumes
docker run -v /var/lib/mysql/data mysql

2. Named Volumes
docker volume create myvol
docker run -v myvol:/var/lib/mysql/data mysql

3. Bind Mounts

Map a host directory to a container directory.

docker run -v /host/data:/var/lib/mysql/data mysql

Volume Commands
docker volume ls
docker volume inspect myvol
docker volume rm myvol

## 8. Docker Compose

Docker Compose runs multi-container applications using a YAML file.

Example docker-compose.yml
version: "3.9"

services:
  web:
    image: nginx
    ports:
      - "8080:80"

  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:

Key Commands
docker compose up -d
docker compose down
docker compose ps
docker compose logs

Benefits of Compose

Multi-container orchestration

Infrastructure as code

Reproducible environments

Easy scaling and updates
