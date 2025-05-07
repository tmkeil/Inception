# Getting Started with Docker: Nginx and WordPress

## What is Docker?

Docker is a platform that allows you to run applications in isolated environments called **containers**. These containers include everything needed to run the application (web server, runtime, libraries), without installing them directly on the host system.
1. Docker is a set of tools to deliver software in containers.
2. Docker is a set of tools to deliver software in containers.

## What is a Container?

A container is a lightweight, standalone unit where an application runs with all its dependencies (e.g., Nginx, PHP, database). Containers are similar to virtual machines but are much more resource-efficient and faster to start.
Containers only contain what is required to execute an application. They are isolated environments in the host machine with the ability to interact with each other and the host machine itself via defined methods (TCP/UDP).
```
docker image ls -a (-a: listing running images)
```

## What is an Image?

Containers are created from images. A Dockerfile is an instruction set for building an image. Images are written by the machine based on the dockerfile.
```
docker container ls -a (-a: listing running containers)
docker ps
docker container rm <id>
If you have hundreds of stopped containers and you wish to delete them all, you should use:
docker container prune / docker image prune
docker system prune

To bring it back:
docker image pull hello-world
```

### Most used commands

| Command                        | Description                        |
| ------------------------------ | ---------------------------------- |
| `docker image ls`         | Lists all images	docker images     |
| `docker image rm <image>` or `docker rmi <imgage>`        | Removes an image	docker     |
| `docker pull <image>`                    | Pulls image from a docker registry	docker pull            |
| `docker container ls -a` or docker ps -a                | Lists all containers  |
| `docker container run <image>` or `docker run`            | Runs a container from an image  |
| `docker container rm <container` or `docker rm`   | Removes a container |
| `docker container stop <container>` or `docker stop` | Stops a container  |
| `docker container exec <container>` or `docker exec` | Executes a command inside the container  |


 <image>	
docker container ls -a	Lists all containers	docker ps -a
docker container run <image>	Runs a container from an image	docker run
docker container rm <container>	Removes a container	docker rm
docker container stop <container>	Stops a container	docker stop
docker container exec <container>	Executes a command inside the container 	docker exec

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
- Requests to `http://<VM-IP>:8080` are forwarded by Docker to port 80 in the container. Inside the container, an Nginx web server listens on port 80 and serves the content.

## Example 1: Static Website with Nginx

### Project Structure

```
nginx-test/
├── docker-compose.yml
└── html/
    └── index.html
```

### docker-compose.yml

```yaml
version: "3.8"

services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
```

### index.html

```html
<!DOCTYPE html>
<html>
  <head><title>Hello Docker</title></head>
  <body><h1>It works!</h1></body>
</html>
```

### Access the Website from the Host

- Open a browser on your host machine (e.g., 42 school computer)
- Go to: `http://<VM-IP>:8080`
- You should see the HTML page served by Nginx running in a Docker container

### Visual Overview:

```
[ Host (e.g. 42-Rechner) ]
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

---

## Example 2: WordPress + MariaDB

This example sets up a working WordPress website with a MariaDB database.

### Project Structure:

```
wordpress-test/
├── docker-compose.yml
└── .env
```

### .env File

```dotenv
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_pass

WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=wp_pass
WORDPRESS_DB_NAME=wordpress
```

### docker-compose.yml

```yaml
version: "3.8"

services:
  db:
    image: mariadb:10.5
    restart: always
    env_file: .env
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:php8.0-apache
    restart: always
    env_file: .env
    ports:
      - "8080:80"
    depends_on:
      - db

volumes:
  db_data:
```

### Start the Services

```bash
cd wordpress-test
docker compose up -d
```

### Access WordPress in the Browser

- Open a browser on your host
- Go to: `http://<VM-IP>:8080`
- The WordPress setup wizard should appear

---

## Why is Docker useful here?

- You don't need to manually install Apache, PHP, MySQL
- It's easy to reset everything with `docker compose down`
- Your data is kept safe in a volume even if the containers stop
- You can move this setup to any machine in seconds

---

## Why was there no .env file in Example 1?

Because Nginx (static site) didn’t need any configuration variables or passwords. Everything was handled with defaults and volumes. In Example 2, `.env` is essential for passing secure credentials and database connection settings.

---

## What does `restart: always` do?

Ensures the container is automatically restarted:

- After a crash
- After the VM or Docker restarts

---

## What does `volumes: db_data:` do?

- Declares a named volume used by the database container
- It stores database files outside the container (in the VM)
- Yes: the data is persistent – even if the container is deleted

Find it here:

```
/var/lib/docker/volumes/db_data/_data/
```

Inside you'll find `.ibd`, `.frm`, and other MariaDB files

---

## Docker Essentials (Summary)

### Useful Commands

| Command                        | Description                        |
| ------------------------------ | ---------------------------------- |
| `docker compose up -d`         | Start containers in background     |
| `docker compose down`          | Stop and remove all containers     |
| `docker ps`                    | List running containers            |
| `docker images`                | List all downloaded Docker images  |
| `docker logs <name>`           | Show logs of a specific container  |
| `docker exec -it <name> sh`    | Start shell in a running container |
| `docker volume inspect <name>` | Show info (and path) for a volume  |

### Inspect MariaDB via Docker

```bash
docker ps  # Get container name
docker exec -it wordpress-test-db bash
mysql -u wp_user -p  # Enter password from .env
```

Then:

```sql
USE wordpress;
SHOW TABLES;
SELECT post_title FROM wp_posts WHERE post_status = 'publish';
```

Exit:

```sql
exit
exit
```

---

## Questions & Answers (Learned Along the Way)

### Why not just install WordPress on the VM?

You could, but:

- Docker is faster, cleaner, easier to reproduce
- No manual dependency management
- Easy to reset and share with others

### What does port 8080 mean?

- 8080 is **opened on the VM** by Docker
- It forwards requests to **port 80 inside the container** (where Nginx or Apache runs)

### Who is listening on which port?

| Port | Where            | Listener                              |
| ---- | ---------------- | ------------------------------------- |
| 8080 | On the VM        | Docker listens, forwards to container |
| 80   | Inside container | Nginx or Apache                       |

### Why no nginx + MariaDB example?

Because:

- MariaDB is a **database**, not a web application
- Nginx is a **webserver**, not a database client
- They don’t interact directly – you need an app (like WordPress) in between

### How do I inspect volume contents?

```bash
sudo ls /var/lib/docker/volumes/db_data/_data
```

---
