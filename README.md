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
| `docker image ls` or `docker images`        | Lists all images	docker images     |
| `docker image rm <image>` or `docker rmi <imgage>`        | Removes an image	docker     |
| `docker pull <image>`                    | Pulls image from a docker registry	docker pull            |
| `docker container ls -a` or docker ps -a                | Lists all containers  |
| `docker container run <image>` or `docker run`            | Runs a container from an image  |
| `docker container rm <container` or `docker rm <container>`   | Removes a container |
| `docker container stop <container>` or `docker stop <container>` | Stops a container  |
| `docker container exec <container>` or `docker exec` | Executes a command inside the container  |

If the image isn't running any service as with the case with ubuntu, then you can instruct docker to run a process.
Execute a command when you run the container:
```
docker run ubuntu sleep 100
```
To execute a command on a running container:
```
docker exec <container name or container id> <command> => for example cat /etc/*release*
```
A container lives just as long as the process inside it is alive
This is why, when you run a container from an ubuntu image, it stops immidiatly. Because ubuntu is just an image of an operating system that is used as the base image for other applications.
There is no process or application in it running by default.

---
 <image>	
docker container ls -a	Lists all containers	docker ps -a
docker container run <image>	Runs a container from an image	docker run
docker container rm <container>	Removes a container	docker rm
docker container stop <container>	Stops a container	docker stop
docker container exec <container>	Executes a command inside the container 	docker exec
 
To run a container in detached mode:
```
docker run -d <image>
```

To attach back to the running detached container run:
```
docker attach <name or id (first few character alone) of the running container>
```

To explore the available images (names) that can be run go to: hub.docker.com/explore

To automatically log in in a container for example:
```
docker run -it centos bash
```

## Run a redis container
```
docker run --name my-redis -p 6379:6379 -d redis
```
--name <name> (sets the name of the container)
-p <portnumber:portnumber> (sets the portnumber)
-d (run in attached mode)
redis (docker image)

docker exec -it my-redis redis-cli

When running:
```
docker run redis:4.0
```
it specifies the version of redis (4.0) ':' is called a tag

When you have a simple prompt program, when running, it aks for an input and shows that input then in the terminal. When you want to dockerize that application and run it as a docker container like : ``docker run tkeil/application``,
the docker container doesn't listen for inputs. It doesn't have a terminal to read input from. For this, run the application in interactive mode with attached to the terminal.
To run a container in interactive mode together with 't' it is attached to the terminal:
```
docker run -it <image>
```
When you run: `docker run -it ubuntu bash`, you are logged in into the bash inside the ubuntu container.

## Port Mapping
The underlying host, where docker is installed is called docker host or docker engine.
When we run a containerized web application, it runs and we are able to see, that the server is running. But how does a user access the application?
When the applcation run on: ``http://0.0.0.0:5000/``, the application listens on port 5000. So one can access the application by accessing port 5000.
But what IP to use, for accessing it from a web browser? There are 2 options:
- 1: use the ip of the docker container (every container gets an ip assigned by default e.g: 172.17.0.2). This ip is an internal ip and is only accessable within the docker host. So for example in a browser inside the docker engine, you can go to http://172.17.0.2:5000 but from outside the engine, this doesn't work.
- For this you can use the ip of the docker host e.g.: 192.168.1.5: But for that to work, you must have mapped the port from inside the docker container to a free port on the docker host. For example, if a user wants to access the app through port 80 from the host, you must port 80 from the docker engine to port 5000 from the container. This is done like that: ``docker run -p 80:5000 <image> ``. In this case a user from outside the docker host can go to: ``http://192.168.1.5:80`` and can connect to the application.
- You can not port more than 2 applications to the same port on the docker host.

## Volume mapping (making data persistent)
When you run docker run mysql, the data is stored inside /var/lib/mysql inside the docker container. (The docker container has its own isolated file system).
When you delete the mysql container and remove it, the container along with all the data inside it gets blown away. If you would like to persist data, you'd like to map a directory outside the container on the docker host to a directory inside the container.
Create a directory on the docker host: /opt/datadir/ and map that to /var/lib/mysql/ is done with '-v' option: ``docker run -v /opt/datadir/:/var/lib/mysql/ mysql``.
Is this way, when docker container runs, it will implicitly mount the external directory to a folder inside the docker container. In this way, all the data will now be stored in the external volume.

## Inspect a container
The docker ps command is good enough to get basic details about names and ids. But if you'd like to see additional details use: docker inspect <docker name or id>
It returns all data in a json format like state, mounts, configurations, network settings ...

## Container logs
How to see the logs of a container, that runs in the background for example if it runs in detached mode?
Use: docker logs <container name or id>

# Creating Images
You create images, if you can't find services that you want to use as part of your application, on docker hub already or you and you team decide that the application, that you develop will be dockerized for ease of shipping and deployment.
How to create an image for a simple web application:
1. You would start from an operating system
2. Update the source repositories using apt
3. Installing the dependecies using apt
4. Install python using pip
5. Copy the source code of the application to a location like /opt
6. Run the webserver using the flask command

You can create a `Dockerfile` that is doing this. For that, create a `Dockerfile`:
```
## [instruction] [argument]
FROM ubuntu

RUN apt-get update
RUN apt-get install -y python python-pip
RUN pip install flask

COPY app.py /opt/app.py

ENTRYPOINT FLASK_APP=/opt/app.py flask run
```

examples:
```
EXPOSE 8080 => exposes port 8080 inside the container
WORKDIR /opt => ...
ENTRYPOINT ["python", "app.py"] => defines 2 commands to run the a service inside a container.
CMD ["executable", "param1"] => Runs this default command, when running the container. When you specify the command in an array format, the first element is the executable, the second the param1... => ["sleep", "5"]

Now: If you only specify only ENTRYPOINT without CMD like:
ENTRYPOINT ["sleep"]
and run the container: docker run <image> 10
it uses the 10 as an argument for the sleep executable. But without the 10 specified, you would get an error.

Together with the CMD option:
ENTRYPOINT ["sleep"]
CMD ["5"]
you can set the 5 as a default value for the sleep executable and it would be overwritten when you run the container by giving for e.g. the 10 as a parameter.

If you want to change the ENTRYPOINT, when you run the container, you can do it with the --entrypoint another_command

```
FROM Ubuntu => defines what the base operating system should be for this container. All Dockerfiles must start with a `FROM` instruction.
Every docker image must be based off from another docker image. Either an os or another image that was created before based on an os.
The RUN instruction instructs docker to run a particullar command on that image.
The COPY instruction copies files from the local system on to the docker image.
The ENTRYPOINT allows to specify a command that will be run when the image is run as a container.

Once done, build the image using: `docker build Dockerfile -t tkeil/my-custom-app`. The '-t' option specifies the name of the image. 'tkeil' is the docker hub account name.
To make this image available on the public docker hub, run the docker push command.

When docker builds the images, it builds these in a layered architecture. Each line of instruction creates a new layer in the docker image with just the changes from the previous layers. You can see the information of the layers by running `docker history <image name>`
So when you stop a build process, it wouldn't has to start all over again, but just from the previous layer saved in the image.

## Environment variables
With docker you can run: `docker run -e APP_COLOR=blue <image>`
'-e VAR_NAME=val' you can set environment variables, that can be used by the program/container. 

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
