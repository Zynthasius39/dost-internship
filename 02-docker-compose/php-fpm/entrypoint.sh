#!/bin/sh

export MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
exec runuser -u www-data -g www-data \
  --whitelist-environment=MYSQL_PASSWORD -- \
  docker-php-entrypoint php-fpm
