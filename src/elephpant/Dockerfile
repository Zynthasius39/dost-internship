FROM docker.io/library/php:8.2-fpm

RUN apt-get update && apt-get install -y \
  libfcgi-bin && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-install pdo pdo_mysql
