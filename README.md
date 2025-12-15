# Dockerized Strapi + PostgreSQL + Nginx

This project sets up a complete Strapi environment using Docker, including:
- PostgreSQL database
- Strapi CMS
- Nginx reverse proxy
- A shared Docker network

Final result: Access the Strapi Admin Panel at **http://localhost/admin**

---

##  Project Structure
my-strapi-project/
│── Dockerfile
│── docker-compose.yml
│── .env
│── nginx/
│ └── nginx.conf
│── src/
│── config/
│── public/
│── package.json
│── yarn.lock

---

##  How to Run

### Start all services
    docker compose up --build

### Stop services
    docker compose down

---

##  PostgreSQL Configuration

PostgreSQL runs inside Docker with:
POSTGRES_USER=strapi
POSTGRES_PASSWORD=strapi123
POSTGRES_DB=strapidb


---

##  Strapi Configuration

Strapi connects to the PostgreSQL container using:

DATABASE_CLIENT=postgres
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=strapidb
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi123

These values are placed in the `.env` file.

---

##  Nginx Reverse Proxy

Nginx listens on port 80 and forwards requests to the Strapi container on port 1337.

Example `nginx.conf`:

```nginx
events {}

http {
  server {
    listen 80;

    location / {
      proxy_pass http://strapi-app:1337;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
    }
  }
}
