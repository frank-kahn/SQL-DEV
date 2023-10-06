cat >  /etc/mysql/mysql55/conf/my.cnf <<"EOF"
[mysqld]
skip-name-resolve
log-bin
server_id=553415
character_set_server=utf8mb4
EOF

cat >  /etc/mysql/mysql56/conf/my.cnf <<"EOF"
[mysqld]
skip-name-resolve
log-bin
server_id=563416
character_set_server=utf8mb4
EOF

cat >  /etc/mysql/mysql57/conf/my.cnf <<"EOF"
[mysqld]
default-time-zone = '+8:00'
log_timestamps = SYSTEM
skip-name-resolve
log-bin
server_id=573417
character_set_server=utf8mb4
EOF

cat >  /etc/mysql/mysql80/conf/my.cnf <<"EOF"
[mysqld]
default-time-zone = '+8:00'
log_timestamps = SYSTEM
skip-name-resolve
log-bin
server_id=803418
character_set_server=utf8mb4
default_authentication_plugin=mysql_native_password
EOF




docker run -d --name mysql55 -h mysql55 -p 3415:3306 \
  -v /etc/mysql/mysql55/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=rootroot -e TZ=Asia/Shanghai \
  mysql:5.5.62

docker run -d --name mysql56 -h mysql56 -p 3416:3306 \
  -v /etc/mysql/mysql56/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=rootroot -e TZ=Asia/Shanghai \
  mysql:5.6.51

docker run -d --name mysql57 -h mysql57 -p 3417:3306 \
  -v /etc/mysql/mysql57/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=rootroot -e TZ=Asia/Shanghai \
  mysql:5.7.43

docker run -d --name mysql80 -h mysql80 -p 3418:3306 \
  -v /etc/mysql/mysql80/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=rootroot -e TZ=Asia/Shanghai \
  mysql:8.0.34

docker run -d --name mysql81 -h mysql81 -p 3419:3306 \
  -v /etc/mysql/mysql81/conf:/etc/mysql/conf.d \
  -e MYSQL_ROOT_PASSWORD=rootroot -e TZ=Asia/Shanghai \
  mysql:8.1.0



docker exec -it mysql55 bash

docker logs -f mysql55
docker logs -f mysql56
docker logs -f mysql57
docker logs -f mysql80
docker logs -f mysql81

mysql -uroot -prootroot -h127.0.0.1 -P3415 -e "select now(),@@hostname,@@version;"
mysql -uroot -prootroot -h127.0.0.1 -P3416 -e "select now(),@@hostname,@@version;"
mysql -uroot -prootroot -h127.0.0.1 -P3417 -e "select now(),@@hostname,@@version;"
mysql -uroot -prootroot -h127.0.0.1 -P3418 -e "select now(),@@hostname,@@version;"
mysql -uroot -prootroot -h127.0.0.1 -P3419 -e "select now(),@@hostname,@@version;"

docker restart mysql55 mysql56 mysql57 mysql80  mysql81
