FROM docker.io/library/php:8.2-fpm

RUN apt-get update && apt-get install -y \
  libfcgi-bin && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-install pdo pdo_mysql

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD SCRIPT_FILENAME=/var/www/html/index.php \
      REQUEST_METHOD=GET \
      REQUEST_URI=/api/health \
      cgi-fcgi -bind -connect 127.0.0.1:9000 || \
      exit 1

USER www-data

EXPOSE 9000
