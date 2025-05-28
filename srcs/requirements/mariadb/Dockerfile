FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY ./conf/init_database.sh ./init.sh

RUN chmod +x ./init.sh

EXPOSE 3306

CMD ["./init.sh"]
