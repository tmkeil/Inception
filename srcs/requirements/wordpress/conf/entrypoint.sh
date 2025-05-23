#!/bin/bash
set -e

# Run the WP installation script
./init.sh

# Start php-fpm
exec /usr/sbin/php-fpm7.4 -F
