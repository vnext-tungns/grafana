#!/bin/sh

_path=$(dirname $0)

docker build --tag mysql-test-db $_path/../docker/blocks/mysql_tests

docker run -p 3306:3306           \
  -d --name mysql-test-db         \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=grafana_tests \
  -e MYSQL_USER=grafana           \
  -e MYSQL_PASSWORD=password      \
  --tmpfs "/var/lib/mysql:rw"     \
  mysql-test-db

sleep 15

docker inspect mysql-test-db

GRAFANA_TEST_DB=mysql go test -v --timeout 10m ./pkg/...
_test_result=$?

docker stop mysql-test-db
docker rm mysql-test-db

exit $_test_result
