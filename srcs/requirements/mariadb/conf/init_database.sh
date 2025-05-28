#!/bin/sh

echo "🟢 test test test1 Starte MariaDB mit Benutzer: $(whoami)"
if [ -z "$DB_ROOT_PASSWORD" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_USER_PASSWORD" ]; then
    echo "❌ Environment variables are missing!"
    exit 1
fi

# Create /run/mysqld directory because mysqld needs it to start and change ownership to mysql
# user and group to avoid permission issues. Because mysql is the user and group that mariadb runs as.
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Initialize the database if it does not exist
# mariadb-install-db is deprecated and replaced by mysqld --initialize
# --initialize is used to create the system tables and the mysql database
echo "🟢 before initializing"
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "✅ Initialisiere Datenbank..."
    #mysql_install_db --user=mysql --datadir=/var/lib/mysql
     mysqld --initialize-insecure --datadir=/var/lib/mysql --user=mysql

    cat << EOF > /tmp/init.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "⚙️  Running the init script..."
    if mysqld --user=mysql --bootstrap < /tmp/init.sql; then
    	rm -f /tmp/init.sql
    else
    	echo "❌ Failed to initialize MariaDB with init.sql"
    	cat /tmp/init.sql
    	exit 1
    fi
else
    echo "📁 Database already exists"
fi
echo "🟢 after finish before trying to start mariadb"
echo "🟢 test Starte MariaDB mit Benutzer: $(whoami)"
# start mariadb server
exec mysqld --socket=/run/mysqld/mysqld.sock
echo "🟢 Starte MariaDB mit Benutzer: $(whoami)"
