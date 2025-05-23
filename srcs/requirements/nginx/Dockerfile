FROM debian:bullseye

RUN apt update && apt upgrade && apt install -y nginx

EXPOSE 80
#EXPOSE 443

COPY ./conf/default /etc/nginx/sites-available/.

CMD ["nginx", "-g", "daemon off;"]
