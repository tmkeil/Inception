#!/bin/bash

set -e

cd /var/www/html

# Download WP-CLI for WordPress management
if [ ! -f wp-cli.phar ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
fi

# Download WordPress
./wp-cli.phar core download --allow-root

# Create wp-config.php to connect wordpress to the mariadb server
if [ ! -f wp-config.php ]; then
  ./wp-cli.phar config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_USER_PASSWORD" --dbhost=mariadb --allow-root
fi

# Install WordPress
if ! ./wp-cli.phar core is-installed --allow-root; then
  ./wp-cli.phar core install \
    --url="$DOMAIN_NAME" \
    --title="inception" \
    --admin_user="$DB_ROOT_USER" \
    --admin_password="$DB_ROOT_PASSWORD" \
    --admin_email="admin@admin.com" \
    --allow-root
fi
