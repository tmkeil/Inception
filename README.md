<div align="center">
  <h1>Inception (42 project)</h1>
</div>

## About
Inception is a systems administration project from the 42 Curriculum. The goal is to build a complete web server infrastructure from scratch using Docker. The entire stack (Nginx, WordPress, MariaDB) runs in isolated containers, orchestrated with Docker Compose.

## Architecture

### Docker & Containerization
Every service runs in its own container, built from a custom Dockerfile. The containers communicate over a shared Docker network (`inception`). The stack consists of:

| Container | Role |
|-----------|------|
| **nginx** | Reverse proxy, TLS termination, static file serving |
| **wordpress** | PHP-FPM 7.4 application server, headless WP-CLI installation |
| **mariadb** | Database server with hardened bootstrap script |

Persistent data is stored in bind-mount volumes mapped to host directories (`~/data/mysql`, `~/data/web`), ensuring data survives container rebuilds.

### Nginx Configuration
Nginx is the single entry point for all traffic. HTTPS is enforced — HTTP requests on port 80 return a `403 Forbidden`. TLS is configured with a self-signed certificate. Dynamic PHP requests are forwarded to the WordPress container via FastCGI on port 9000.

### WordPress Setup
WordPress is installed automatically and headlessly during container startup using WP-CLI. The `install_wp.sh` script checks whether WordPress core files and `wp-config.php` already exist before downloading or configuring anything, so containers can restart cleanly without breaking the setup. PHP-FPM listens on `wordpress:9000`, keeping the application server decoupled from the web server.

### MariaDB Initialization
On first launch, `init_database.sh` bootstraps the database securely:
- Removes anonymous users and the test database
- Disables remote root access
- Creates the WordPress database

On subsequent starts, the script detects the existing data directory and skips initialization.

## Usage
Clone the repository:
```
git clone https://github.com/tmkeil/Inception.git && cd Inception
```

Create a `.env` file in `srcs/` with the required variables:
```
DOMAIN_NAME=<your domain, e.g. login.42.fr>
DB_NAME=<database name>
DB_ROOT_USER=root
DB_ROOT_PASSWORD=<root password>
DB_USER=<database user>
DB_USER_PASSWORD=<database user password>
WP_ADMIN_USER=<WordPress admin username>
WP_ADMIN_PASSWORD=<WordPress admin password>
WP_ADMIN_EMAIL=<WordPress admin email>
```

Build and start everything:
```
make
```

Add your domain to `/etc/hosts` so the browser can resolve it locally:
```
echo "127.0.0.1 <DOMAIN_NAME>" | sudo tee -a /etc/hosts
```

The site is then available at `https://<DOMAIN_NAME>`.

| Command | Description |
|---------|-------------|
| `make` | Build images, create volumes, start all services |
| `make down` | Stop all containers |
| `make clean` | Stop and prune unused resources |
| `make fclean` | Full reset — remove containers, volumes, images, and cache |
| `make re` | Full reset + rebuild |
