FROM debian:bullseye

RUN apt update && apt upgrade && apt install -y php7.4-fpm

EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/.

# Erstelle Socket-Verzeichnis für php-fpm
RUN mkdir -p /run/php

CMD ["/usr/sbin/php-fpm7.4", "-F"]
