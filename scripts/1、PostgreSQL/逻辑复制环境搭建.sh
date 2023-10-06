#!/bin/sh


# 检查是否存在docker，存在的话遍历删除
if [[ $(docker ps -a|awk 'NR>1 {print $NF}'|wc -l) -gt 0 ]]
then
for i in $(docker ps -a|awk 'NR>1 {print $NF}');do
docker rm -f $i
done
fi


# 检查网络是否存在，存在就删除
if [[ $(docker network ls|awk '{print $2}'|grep -o pg-network|wc -l) -gt 0 ]]
then
docker network rm -f $(docker network ls|awk '{print $2}'|grep -o pg-network)
fi

# 创建专用网络
docker network create --subnet=172.72.6.0/24 pg-network


# PUBLICATION(发布) 
docker run -d --name pghost_pub -h pghost_pub \
  -p 15432:5433 --net=pg-network --ip 172.72.6.10 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true pg9_13:1.0 \
  /usr/sbin/init



# SUBSCRIPTION(订阅) 
docker run -d --name pghost_sub -h pghost_sub \
  -p 15433:5433 --net=pg-network --ip 172.72.6.11 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true pg9_13:1.0 \
  /usr/sbin/init

echo -e "\033[32m------------------------------STARTING PUBLICATION SETTING-------------------------------------\033[0m"
#启动docker里面数据库服务
docker exec pghost_pub bash -c "su - pg12 -c \"pg_ctl start\""
docker exec pghost_sub bash -c "su - pg12 -c \"pg_ctl start\""
#修改docker里面数据库密码
docker exec pghost_pub bash -c "su - pg12 -c \"psql -c \\\"alter user postgres with password 'postgres'\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql -c \\\"alter user postgres with password 'postgres'\\\"\""


#发布节点配置
docker exec pghost_pub bash -c "echo 'host      all     repuser   172.72.6.11/32   trust' >> /pg12/pgdata/pg_hba.conf"
docker exec pghost_pub bash -c "echo 'wal_level = logical' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_pub bash -c "echo \"listen_addresses = '*'\" >> /pg12/pgdata/postgresql.conf"
docker exec pghost_pub bash -c "echo 'max_replication_slots = 20' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_pub bash -c "echo 'max_wal_senders = 100' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_pub bash -c "su - pg12 -c \"pg_ctl restart\""
#打印发布节点的参数信息
echo -e "\033[32m------------------------------PUBLICATION PARAMETERS-------------------------------------\033[0m"
docker exec pghost_pub bash -c "su - pg12 -c \"psql -c \\\"select name,setting,unit,context from pg_settings where name in ('wal_level','archive_mode','archive_command','listen_addresses','max_replication_slots','max_wal_senders')\\\"\""
#发布节点创建复制用户和数据库
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15432/postgres -c \\\"CREATE USER repuser REPLICATION ENCRYPTED PASSWORD 'repuser'\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15432/postgres -c \\\"create database sysbenchdb with owner=repuser\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15432/postgres -c \\\"CREATE SCHEMA AUTHORIZATION repuser\\\"\""
#发布节点使用sysbench创建测试数据
docker exec pghost_pub bash -c "su - pg12 -c \"sysbench /usr/share/sysbench/oltp_write_only.lua --db-driver=pgsql --pgsql-db=sysbenchdb --pgsql-host=127.0.0.1 --pgsql-port=5433 --pgsql-user=repuser --pgsql-password=repuser --table-size=100000 --tables=10 --threads=8 prepare\""
#发布节点创建发布
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest1 FOR TABLE sbtest1;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest2 FOR TABLE sbtest2;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest3 FOR TABLE sbtest3;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest4 FOR TABLE sbtest4;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest5 FOR TABLE sbtest5;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest6 FOR TABLE sbtest6;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest7 FOR TABLE sbtest7;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest8 FOR TABLE sbtest8;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest9 FOR TABLE sbtest9;\\\"\""
docker exec pghost_pub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15432/sysbenchdb -c \\\"create PUBLICATION pub_sbtest10 FOR TABLE sbtest10;\\\"\""





echo -e "\033[32m------------------------------STARTING SUBLICATION SETTING-------------------------------------\033[0m"
#订阅节点参数配置
docker exec pghost_sub bash -c "echo 'max_logical_replication_workers = 20' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_sub bash -c "echo 'max_worker_processes = 20' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_sub bash -c "echo 'max_replication_slots = 100' >> /pg12/pgdata/postgresql.conf"
docker exec pghost_sub bash -c "su - pg12 -c \"pg_ctl restart\""
#订阅节点创建测试数据库
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15433/postgres -c \\\"create user repuser password 'repuser' superuser\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15433/postgres -c \\\"create database testdb with owner=repuser\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://postgres:postgres@192.168.1.100:15433/postgres -c \\\"CREATE SCHEMA AUTHORIZATION repuser\\\"\""
#订阅节点创建接收表
docker exec pghost_sub bash -c "su - pg12 -c \"sysbench /usr/share/sysbench/oltp_write_only.lua --db-driver=pgsql --pgsql-db=testdb --pgsql-host=127.0.0.1 --pgsql-port=5433 --pgsql-user=repuser --pgsql-password=repuser --table-size=0 --tables=10 --threads=8 prepare\""
#订阅发布
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest1 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest1;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest2 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest2;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest3 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest3;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest4 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest4;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest5 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest5;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest6 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest6;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest7 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest7;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest8 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest8;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest9 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest9;\\\"\""
docker exec pghost_sub bash -c "su - pg12 -c \"psql postgresql://repuser:repuser@192.168.1.100:15433/testdb -c \\\"create subscription sub_sbtest10 connection 'host=172.72.6.10 port=5433 dbname=sysbenchdb user=repuser password=repuser' publication pub_sbtest10;\\\"\""




