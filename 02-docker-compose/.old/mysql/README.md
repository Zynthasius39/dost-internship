### MySQL root istifadəsi üçün hash çıxarmaq

``` sh
PASSWORD=123  # Password that will be hashed
CONTAINER_ID=$(docker run -d --rm -e MYSQL_ROOT_PASSWORD=$PASSWORD docker.io/library/mysql:8.0.45-bookworm)
while ! docker exec $CONTAINER_ID mysqladmin ping -h localhost -p$PASSWORD --silent; do
  sleep 1
done
sleep 5  # This may fail. If that is the case, try the later command after the container is fully initialized.
docker exec -it $CONTAINER_ID \
  bash -c "mysql -p$PASSWORD -ss -e \"SELECT CONCAT('0x', HEX(authentication_string)) FROM mysql.user WHERE host='localhost' and user='root';\" 2>/dev/null" \
  > ./secrets/mysql-root
docker rm -f $CONTAINER_ID
```
