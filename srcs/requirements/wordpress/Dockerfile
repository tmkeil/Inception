FROM debian:bullseye

RUN apt update && apt upgrade -y && apt install -y php7.4-fpm php7.4-mysql curl

EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/.
COPY ./conf/install_wp.sh ./init.sh
COPY ./conf/entrypoint.sh ./entrypoint.sh

RUN chmod +x ./init.sh ./entrypoint.sh && mkdir -p /run/php

ENTRYPOINT ["./entrypoint.sh"]


