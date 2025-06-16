# Inception

## Project Objective

The goal of the Inception project is to build a secure, modular web server infrastructure using Docker. The architecture consists of three core services (Nginx, WordPress, and MariaDB), each running in its own isolated container. These services communicate via a shared Docker network and are configured to work seamlessly together.

Configuration files define how the services behave and how they connect, but the actual communication between them is handled via Docker's networking. The configuration files control aspects such as hostnames, ports, credentials, and service-specific behavior.

## Service Overview

### 1. **Nginx**

* Acts as a reverse proxy and entry point for incoming HTTP and HTTPS requests.
* SSL encryption is enabled using a custom configuration file (`default`):

```nginx
listen 443 ssl;
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
```

* PHP files are forwarded to the WordPress container running PHP-FPM:

```nginx
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass wordpress:9000;
}
```

* The hostname `wordpress` refers to the WordPress container in the shared network.

👉 You can find the full configuration [here](https://github.com/tmkeil/Inception/blob/main/srcs/requirements/nginx/conf/default).

### 2. **WordPress**

* Hosts a PHP application (WordPress) that is automatically installed and configured via a shell script during container startup.
* PHP-FPM listens on port `9000`, allowing Nginx to forward dynamic requests.
* The setup ensures proper separation of static and dynamic content processing.

### 3. **MariaDB**

* Manages the WordPress database.
* During its first launch, `init_database.sh` does the following:

  * Removes default users and test data.
  * Creates a database with UTF-8 encoding.
  * Sets passwords and access permissions.

👉 Full script available [here](https://github.com/tmkeil/Inception/blob/main/srcs/requirements/mariadb/conf/init_database.sh).

## Networking

All services are connected through a custom Docker network called `inception`. This allows containers to resolve each other by name (e.g., `wordpress`, `mariadb`) and communicate internally.

## Data Persistence

* Data is persisted using named volumes mounted from the host system.
* These volumes prevent data loss on container restart or rebuild.
* Created via the `Makefile`:

```bash
docker volume create --name mariadb_data --driver local --opt type=none --opt device=/home/$(USER)/data/mysql --opt o=bind
docker volume create --name wordpress_data --driver local --opt type=none --opt device=/home/$(USER)/data/web --opt o=bind
```

* Used in `docker-compose.yml` to mount directories into the containers.

---

## Project Flow

* The project is started by running `make`, which triggers the `Makefile`.
* The `Makefile` creates the named volumes and starts the services using `docker-compose.yml`.
* Each service has its own `Dockerfile` based on `debian:bullseye`.

### Nginx Dockerfile:

* Copies the custom `default` configuration into `/etc/nginx/sites-available/`.
* This directory is used by Nginx to store site-specific configurations, which are then enabled.
* Runs `CMD ["nginx", "-g", "daemon off;"]` to keep the Nginx process in the foreground.

### MariaDB Dockerfile:

* Copies `50-server.cnf` into `/etc/mysql/mariadb.conf.d/`, which overrides default database settings such as user, bind address, data directory, and locale settings.
* Also copies `init_database.sh` into the container as `init.sh`.

### WordPress Dockerfile:

* Based on `debian:bullseye`.
* Installs required packages: `php7.4-fpm`, `php7.4-mysql`, and `curl`.
* Exposes port `9000` for PHP-FPM.
* Copies:

  * `www.conf` to configure PHP-FPM pool.
  * `install_wp.sh` as the main WordPress setup script.
  * `entrypoint.sh` as the container entrypoint.
* Makes scripts executable and creates required directories.
* Uses `ENTRYPOINT ["./entrypoint.sh"]` to control startup behavior.

---


# Getting Started with Docker: Nginx and WordPress

## What is Docker?

Docker is a platform that allows you to run applications in isolated environments called **containers**. These containers include everything needed to run the application (web server, runtime, libraries), without installing them directly on the host system.

Key points:

1. Docker provides tools to package software in containers.
2. Containers run the same way across different systems, ensuring portability.

## What is a Container?

A container is a lightweight, standalone unit where an application runs with all its dependencies (e.g., Nginx, PHP, database). Containers are similar to virtual machines but are more resource-efficient and faster to start.

* Containers are isolated environments.
* They only contain what's necessary to run the app.
* They can communicate with each other and the host system through defined interfaces.

Example:

```bash
docker image ls -a # Lists all images, including intermediate ones
```

## What is an Image?

Containers are created from images. An image is a read-only template that contains a set of instructions for creating a container.

You can create your own image using a `Dockerfile`, which contains a list of steps to build that image.

Common commands:

```bash
docker container ls -a      # Lists all containers
docker ps                   # Also lists containers (shorthand)
docker container rm <id>    # Removes a container
```

To clean up unused resources:

```bash
docker container prune
docker image prune
docker system prune
```

To pull a fresh image:

```bash
docker image pull hello-world
```

## Most Used Docker Commands

| Command                                   | Description                             |
| ----------------------------------------- | --------------------------------------- |
| `docker image ls` or `docker images`      | Lists all images                        |
| `docker image rm <image>`                 | Removes an image                        |
| `docker pull <image>`                     | Pulls an image from Docker Hub          |
| `docker container ls -a`                  | Lists all containers                    |
| `docker container run <image>`            | Runs a container from an image          |
| `docker container rm <container>`         | Removes a container                     |
| `docker container stop <container>`       | Stops a running container               |
| `docker container exec <container> <cmd>` | Executes a command inside the container |

Example:

```bash
docker exec <container_id> cat /etc/*release*
```

A container only runs as long as the internal process is running. For example, `ubuntu` containers stop immediately because there is no running process by default.

Running a container in interactive mode:

```bash
docker run -it ubuntu bash
```

## Detached Mode

Run a container in the background:

```bash
docker run -d <image>
```

Attach back to it:

```bash
docker attach <container_id>
```

Explore available images:
[hub.docker.com/explore](https://hub.docker.com/explore)

## Running a Redis Container

```bash
docker run --name my-redis -p 6379:6379 -d redis
```

Then connect to it:

```bash
docker exec -it my-redis redis-cli
```

Specify an image version:

```bash
docker run redis:4.0
```

## Port Mapping

To access containerized apps externally, map ports from container to host:

```bash
docker run -p 80:5000 <image>
```

This maps port 5000 in the container to port 80 on the host.

Access:

* From inside Docker: [http://172.17.0.2:5000](http://172.17.0.2:5000)
* From host/browser: [http://192.168.1.5:80](http://192.168.1.5:80) (if host IP is 192.168.1.5)

## Volume Mapping (Persistent Data)

To persist data outside the container:

```bash
docker run -v /opt/datadir/:/var/lib/mysql/ mysql
```

This maps `/opt/datadir/` on the host to `/var/lib/mysql/` in the container.

## Inspect a Container

```bash
docker inspect <container>
```

Shows configuration, environment, volumes, network, etc.

## View Logs

```bash
docker logs <container>
```

Useful for debugging containers running in detached mode.

## Creating Docker Images

If you can't find a suitable image or want to dockerize your app:

1. Start with a base image
2. Install dependencies
3. Copy your source code
4. Run the application

Example Dockerfile:

```Dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install flask
COPY app.py /opt/app.py
ENTRYPOINT FLASK_APP=/opt/app.py flask run
```

Build and tag the image:

```bash
docker build -t yourname/my-custom-app .
```

Push it:

```bash
docker push yourname/my-custom-app
```

## Dockerfile Instructions Explained

* `FROM`: sets the base image
* `RUN`: executes commands during image build
* `COPY`: copies files from host to image
* `ENTRYPOINT`: defines the command to run the app
* `CMD`: provides default arguments to ENTRYPOINT

Example:

```Dockerfile
ENTRYPOINT ["sleep"]
CMD ["5"]
```

Run:

```bash
docker run myimage 10 # will override CMD to "10"
```

Change ENTRYPOINT dynamically:

```bash
docker run --entrypoint <command> <image>
```

---

