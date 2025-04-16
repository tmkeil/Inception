# Getting Started with Docker and Nginx

## What is Docker?

Docker is a platform that allows you to run applications in isolated environments called **containers**. These containers include everything needed to run the application (web server, runtime, libraries), without installing them directly on the host system.

## What is a Container?

A container is a lightweight, standalone unit where an application runs with all its dependencies (e.g., Nginx, PHP, database). Containers are similar to virtual machines but are much more resource-efficient and faster to start.

## What Does Docker Do?

Docker:
- Creates and manages containers
- Includes all dependencies and configuration within the container
- Enables starting, stopping, and networking these containers easily

## Port Mapping Explained (`"8080:80"`)

When using the following line in a Docker Compose file:

```yaml
ports:
  - "8080:80"
```

It means:
- Port 8080 on the host (your VM) is opened
- Requests to http://<VM-IP>:8080 are forwarded by Docker to port 80 in the container inside the container, an Nginx web server listens on port 80 and serves the content

## Example Project Structure with Nginx
```yaml
nginx-test/
├── docker-compose.yml
└── html/
    └── index.html
```
```
Example docker-compose.yml
version: "3.8"

services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
```
```
Example index.html
<!DOCTYPE html>
<html>
  <head><title>Hello Docker</title></head>
  <body><h1>It works!</h1></body>
</html>
```

## How to Access the Website from the Host

- Open a browser on your host machine (e.g., 42 school computer)
- Go to: http://<VM-IP>:8080
- You should see the HTML page served by Nginx running in a Docker container

(Docker öffnet Port 8080 meiner VM und leitet Anfragen an den Container Port 80 von nginx weiter)
```
[ Host (z. B. 42-Rechner) ]
            |
      http://10.12.249.125:8080
            |
[ VM ] -- Port 8080 --> [ Docker Engine ]
                           |
                           v
[ Container: Nginx ] <-- Port 80
          |
     index.html
```

## Essential Docker Commands

Command

Description

docker compose up -d

Start containers in detached mode

docker compose down

Stop and remove containers

docker ps

List running containers

docker images

List downloaded Docker images

docker logs <container-name>

Show logs of a specific container

docker exec -it <container> sh

Open a shell inside a running container
