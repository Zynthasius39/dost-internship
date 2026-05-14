# Docker Compose

<img src="img/docker-mark-ocean-blue.svg" width="100">

---
<!-- toc -->

- [Docker Compose](#docker-compose)
  - [Tələblər](#tələblər)
    - [Lazımlı qovluqları
      yarat](#lazımlı-qovluqları-yarat)
    - [Loq qovluqlarının icazələrini
      düzəlt](#loq-qovluqlarının-icazələrini-düzəlt)
    - [Secret fayllarında istifadə etmək üçün kodlar
      yarat](#secret-fayllarında-istifadə-etmək-üçün-kodlar-yarat)
  - [Tapşırıq siyahısı](#tapşırıq-siyahısı)
    - [Reverse Proxy
      Layer](#reverse-proxy-layer)
      - [NGINX container](#nginx-container)
      - [Hostda 8080 portundan
        açılmalıdır](#hostda-8080-portundan-açılmalıdır)
      - [PHP requestləri application container-inə forward
        etməlidir](#php-requestləri-application-container-inə-forward-etməlidir)
      - [Config external fayldan gəlməlidir (image içində
        olmamalıdır)](#config-external-fayldan-gəlməlidir-image-içində-olmamalıdır)
      - [Container database şəbəkəsinə çıxış edə
        bilməməlidir](#container-database-şəbəkəsinə-çıxış-edə-bilməməlidir)
    - [Application Layer](#application-layer)
      - [PHP-FPM container](#php-fpm-container)
      - [Source kod hostdan mount
        edilməlidir](#source-kod-hostdan-mount-edilməlidir)
      - [DB ilə əlaqə
        qurmalıdır](#db-ilə-əlaqə-qurmalıdır)
      - [Healthcheck
        olmalıdır](#healthcheck-olmalıdır)
      - [Container crash edərsə restart
        olunmalıdır](#container-crash-edərsə-restart-olunmalıdır)
      - [Root user ilə
        işləməməlidir](#root-user-ilə-işləməməlidir)
    - [Database Layer](#database-layer)
      - [MySQL 8 container](#mysql-8-container)
      - [Data persistent
        olmalıdır](#data-persistent-olmalıdır)
      - [Root password plain text
        yazılmamalıdır](#root-password-plain-text-yazılmamalıdır)
      - [Application user ayrıca
        yaradılmalıdır](#application-user-ayrıca-yaradılmalıdır)
      - [DB container internetə çıxışı
        olmamalıdır](#db-container-internetə-çıxışı-olmamalıdır)
      - [Healthcheck
        olmalıdır](#healthcheck-olmalıdır-1)
    - [Network tələbləri](#network-tələbləri)
      - [Minimum 2 ayrı Docker
        network](#minimum-2-ayrı-docker-network)
      - [Frontend DB-yə birbaşa qoşula
        bilməməlidir](#frontend-db-yə-birbaşa-qoşula-bilməməlidir)
      - [Application həm DB, həm Front network-də
        olmalıdır](#application-həm-db-həm-front-network-də-olmalıdır)
    - [Təhlükəsizlik
      tələbləri](#təhlükəsizlik-tələbləri)
      - [Secrets istifadə
        olunmalıdır](#secrets-istifadə-olunmalıdır)
    - [Production-a
      hazırlıq](#production-a-hazırlıq)
      - [Resource limits](#resource-limits)
      - [Proper restart
        policies](#proper-restart-policies)
      - [Named volumes](#named-volumes)
      - [.env istifadəsi](#env-istifadəsi)
      - [Logging
        stdout/stderr](#logging-stdoutstderr)

<!-- tocstop -->

---
## Tələblər

### Lazımlı qovluqları yarat

``` sh
for DIR in logs/{nginx,php-fpm,mysql} secrets; do
  mkdir -vp ./$DIR
done
```

### Loq qovluqlarının icazələrini düzəlt

``` sh
chown 33:33 ./logs/php-fpm
chown 999:999 ./logs/mysql
```

### Secret fayllarında istifadə etmək üçün kodlar yarat

``` sh
for MYSQL_USER in root dostdev; do
  openssl rand -base64 24 > ./secrets/mysql-$MYSQL_USER \
    && chmod 400 ./secrets/mysql-$MYSQL_USER
done
```

## Tapşırıq siyahısı

### Reverse Proxy Layer

#### NGINX container

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
+   image: docker.io/library/nginx:1.29.6-alpine
    ports:
      - 8080:80
  ...
```

#### Hostda 8080 portundan açılmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    image: docker.io/library/nginx:1.29.6-alpine
+   ports:
+     - 8080:80
    volumes:
      - ./nginx/docker.dost.edu.az.conf:/etc/nginx/conf.d/docker.dost.edu.az.conf:ro
      - ./logs/nginx:/var/log/nginx
    networks:
      api:
    restart: unless-stopped
  ...
```

#### PHP requestləri application container-inə forward etməlidir

_[nginx/docker.host.edu.az.conf](nginx/docker.dost.edu.az.conf)_
``` diff
  ...
    location / {
      include fastcgi_params;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
+     fastcgi_pass application:9000;
    }
  ...
```

#### Config external fayldan gəlməlidir (image içində olmamalıdır)

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    image: docker.io/library/nginx:1.29.6-alpine
    ports:
      - 8080:80
    volumes:
+     - ./nginx/docker.dost.edu.az.conf:/etc/nginx/conf.d/docker.dost.edu.az.conf:ro
      - ./logs/nginx:/var/log/nginx
    networks:
      api:
    restart: unless-stopped
```

#### Container database şəbəkəsinə çıxış edə bilməməlidir

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    image: docker.io/library/nginx:1.29.6-alpine
    ...
    networks:
      api:
-     database:
    restart: unless-stopped
  ...
```

### Application Layer

#### PHP-FPM container

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
  application:
+   build:
+     dockerfile: php-fpm.Dockerfile
    env_file: ./php-fpm.env
  ...
```

_[Dockerfile](php-fpm/Dockerfile)_
``` diff
+ FROM docker.io/library/php:8.2-fpm

  RUN apt-get update && apt-get install -y \
    libfcgi-bin && \
  ...
```

#### Source kod hostdan mount edilməlidir

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
    env_file: ./php-fpm.env
    volumes:
+     - ./php-fpm/html:/var/www/html:ro
      - ./php-fpm/php-fpm.conf:/usr/local/etc/php-fpm.conf
  ...
```

#### DB ilə əlaqə qurmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
  application:
    build:
      dockerfile: php-fpm.Dockerfile
+   env_file: ./php-fpm.env
    volumes:
  ...
```

_[index.php](php-fpm/html/index.php)_
``` diff
  ...
  if ($host && $user && $password && $db) {
      try {
+         $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $password);
          $tests['database'] = 'Connected OK';
      } catch (Exception $e) {
  ...
```

``` sh
curl -H "Host: docker.dost.edu.az" http://localhost:8080
```
``` console
{
    "php_version": "8.2.30",
    "database": "Connected OK"
}
```

#### Healthcheck olmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
    env_file: ./php-fpm.env
+   healthcheck:
+     test:
+       - CMD-SHELL
+       - |
+         SCRIPT_FILENAME=/var/www/html/index.php
+         REQUEST_METHOD=GET
+         REQUEST_URI=/api/health
+         cgi-fcgi -bind -connect 127.0.0.1:9000 ||
+         exit 1
+     interval: 10s
+     timeout: 5s
+     retries: 5
+     start_period: 10s
    networks:
  ...
```

#### Container crash edərsə restart olunmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
      start_period: 10s
    networks:
      api:
      db:
+   restart: unless-stopped
    secrets:
      - mysql-dostdev
    volumes:
  ...
```

#### Root user ilə işləməməlidir

Root user ilə işləməyəndə docker secret-i oxumaq olmurdu ona görə custom entrypoint yazdım. Əsas *php-fpm* prosesi *www-data* kimi işləyir.

_[entrypoint.sh](php-fpm/entrypoint.sh)_
``` diff
  #!/bin/sh

  export MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
+ exec runuser -u www-data -g www-data \
    --whitelist-environment=MYSQL_PASSWORD -- \
    docker-php-entrypoint php-fpm
```

Container-də heç root proses olmaması üçün secret-i build vaxtı əlavə etmək lazımdır.

``` sh
docker-compose exec application ps -ef
```
``` console
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 22:43 ?        00:00:00 runuser -u www-data -g www-data --whitelist-environment=MYSQL_PASSWORD -- docker-php-entrypoint php-fpm
www-data       8       1  0 22:43 ?        00:00:00 php-fpm: master process (/usr/local/etc/php-fpm.conf)
www-data       9       8  0 22:43 ?        00:00:00 php-fpm: pool www
www-data      10       8  0 22:43 ?        00:00:00 php-fpm: pool www
root         963       1  0 23:05 ?        00:00:00 [dpkg-preconfigu] <defunct>
root        1066       0 50 23:05 ?        00:00:00 ps -ef
```

### Database Layer

#### MySQL 8 container

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
  database:
    env_file: ./mysql.env
+   image: docker.io/library/mysql:8.0.45-bookworm
    networks:
  ...
```

#### Data persistent olmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
      - mysql-dostdev
    volumes:
      - ./logs/mysql:/var/log/mysql
+     - db-data:/var/lib/mysql
  ...
```

#### Root password plain text yazılmamalıdır

#### Application user ayrıca yaradılmalıdır

_[mysql.env](mysql.env)_
``` diff
+ MYSQL_USER=dostdev
  MYSQL_DATABASE=dostdev
+ MYSQL_PASSWORD_FILE=/run/secrets/mysql-dostdev
  MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql-root
```

#### DB container internetə çıxışı olmamalıdır

``` diff
  ...
  networks:
    api:
+   db:
+     internal: true
  ...
```

#### Healthcheck olmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  database:
    env_file: ./mysql.env
+   healthcheck:
+     test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
+     interval: 10s
+     timeout: 5s
+     retries: 5
+     start_period: 10s
    image: docker.io/library/mysql:8.0.45-bookworm
```

### Network tələbləri

#### Minimum 2 ayrı Docker network

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
+ networks:
+   api:
+   db:
+     internal: true
```

#### Frontend DB-yə birbaşa qoşula bilməməlidir

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    image: docker.io/library/nginx:1.29.6-alpine
    ...
    networks:
      api:
-     database:
    restart: unless-stopped
  ...
```

#### Application həm DB, həm Front network-də olmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  application:
    build: php-fpm
    ...
+   networks:
+     api:
+     db:
    restart: unless-stopped
  ...
```

### Təhlükəsizlik tələbləri

#### Secrets istifadə olunmalıdır

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
+ secrets:
+   mysql-dostdev:
+     file: ./secrets/mysql-dostdev
+   mysql-root:
+     file: ./secrets/mysql-root
  ...
```

### Production-a hazırlıq

Aşağıdakılar əlavə olunmalıdır.

#### Resource limits

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    ...
+   deploy:
+     resources:
+       limits:
+         cpus: 0.5
+         memory: 128M
+       reservations:
+         cpus: 0.1
+         memory: 32M
    ...

  application:
    ...
+   deploy:
+     resources:
+       limits:
+         cpus: 1.0
+         memory: 512M
+       reservations:
+         cpus: 0.25
+         memory: 128M
    ...

  database:
    ...
+   deploy:
+     resources:
+       limits:
+         cpus: 2.0
+         memory: 2G
+       reservations:
+         cpus: 0.5
+         memory: 512M
    ...
  ...
```

#### Proper restart policies

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
services:
  reverse-proxy:
    ...
+   restart: unless-stopped
    ...

  application:
    ...
+   restart: unless-stopped
    ...

  database:
    ...
+   restart: unless-stopped
    ...
  ...
```

#### Named volumes

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
  database:
    ...
    volumes:
      - ./logs/mysql:/var/log/mysql
+     - db-data:/var/lib/mysql
  ...
```

#### .env istifadəsi

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  ...
  application:
    ...
+   env_file: ./php-fpm.env
    ...

  database:
+   env_file: ./mysql.env
    ...
  ...
```

#### Logging stdout/stderr

_[docker-compose.yaml](docker-compose.yaml)_
``` diff
  services:
    reverse-proxy:
      ...
      volumes:
        - ./nginx/docker.dost.edu.az.conf:/etc/nginx/conf.d/docker.dost.edu.az.conf:ro
+       - ./logs/nginx:/var/log/nginx

    application:
      ...
      volumes:
        - ./php-fpm/html:/var/www/html:ro
        - ./php-fpm/entrypoint.sh:/entrypoint.sh:ro
        - ./php-fpm/php-fpm.conf:/usr/local/etc/php-fpm.conf:ro
+       - ./logs/php-fpm:/var/log/php-fpm

    database:
      ...
      volumes:
        - ./mysql/logging.cnf:/etc/mysql/conf.d/logging.cnf:ro
        - db-data:/var/lib/mysql
+       - ./logs/mysql:/var/log/mysql
  ...
```
