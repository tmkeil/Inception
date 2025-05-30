#!/bin/sh

if [ ! -d /run/mysqld ]; then
    mkdir -p /run/mysqld
    chown mysql:mysql /run/mysqld
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "✅ Initialisiere Datenbank..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

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

    echo "⚙️ Führe einmalig init.sql mit bootstrap aus..."
    if ! mysqld --user=mysql --bootstrap < /tmp/init.sql; then
        echo "❌ Fehler beim Ausführen von init.sql"
        cat /tmp/init.sql
        exit 1
    fi
    rm -f /tmp/init.sql
else
    echo "📁 Datenbank bereits initialisiert, überspringe Init."
fi

echo "🟢 Starte regulär MariaDB..."
exec mysqld --socket=/run/mysqld/mysqld.sock

