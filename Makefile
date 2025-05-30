all: build

build:
	echo "Creating the data directory and volumes..."
	#mkdir -p /home/$(USER)/data/mysql /home/$(USER)/data/web
	docker volume create --name mariadb_data --driver local --opt type=none --opt device=/home/$(USER)/data/mysql --opt o=bind
	docker volume create --name wordpress_data --driver local --opt type=none --opt device=/home/$(USER)/data/web --opt o=bind
	echo "Building and starting the containers...\n"
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
	docker volume rm mariadb_data wordpress_data || true

re: fclean all

.PHONY: all build down clean fclean re

.SILENT:

