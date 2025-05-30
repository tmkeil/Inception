#!/bin/bash
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DOMAIN_NAME: $DOMAIN_NAME"
set -e

cd /var/www/html

# https://wp-cli.org/#installing
# Download WP-CLI for WordPress management
if [ ! -f wp-cli.phar ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
fi

# https://developer.wordpress.org/cli/commands/core/
# Download WordPress
if [ ! -f wp-load.php ]; then
  ./wp-cli.phar core download --allow-root
else
  echo "WordPress files already exist, skipping download."
fi

# https://developer.wordpress.org/cli/commands/config/create/
# Create wp-config.php to connect wordpress to the mariadb server
if [ ! -f wp-config.php ]; then
  ./wp-cli.phar config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_USER_PASSWORD" --dbhost=mariadb --allow-root
fi

# Install WordPress
if ! ./wp-cli.phar core is-installed --allow-root; then
  ./wp-cli.phar core install \
    --url="$DOMAIN_NAME" \
    --title="inception" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root
else
  echo "WordPress is already installed."
fi

