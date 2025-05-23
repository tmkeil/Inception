all: build

build:
	echo "Creating the data mount directory and building the containers...\n"
	docker compose -f ./srcs/docker-compose.yml up --build -d

down:
	echo "Stopping the containers...\n"
	docker compose -f ./srcs/docker-compose.yml down

clean: down
	echo "Removing all stopped containers"
	docker system prune -a --force

fclean: clean
	echo "Stopping all running containers...\n"
	if [ -n "$$(docker ps -q)" ]; then docker stop $$(docker ps -q); fi
	echo "Removing all stopped containers, unused networks, dangling images, unused volumes and build cache...\n"
	docker system prune --all --force --volumes

re: fclean all

.PHONY: all build down clean fclean re

.SILENT:
