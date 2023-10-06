#连接数据库
psql postgresql://postgres:postgres@192.168.1.100:15432/postgres
psql postgresql://test:test@192.168.1.100:15432/testdb  

#创建centos容器13.2
docker run -d --name pghost1 -h pghost1 \
-p 15432-15439:5432-5439 -p 13389:3389 \
-v /sys/fs/cgroup:/sys/fs/cgroup \
--privileged=true pg13.2:1.0 \
/usr/sbin/init

#多个版本
docker run -d --name pghost1 -h pghost1 \
  -p 15432-15439:5432-5439 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true pg9_13:1.0 \
  /usr/sbin/init

#进入centos容器
docker exec -it pghost1 bash
su - pg12 -c "pg_ctl start"
su - pg12 -c "psql -c \"alter user postgres with password 'postgres'\""


############################ 主从搭建 ##############################
# 创建专用网络
docker network create --subnet=172.72.6.0/24 pg-network

# 主库
docker run -d --name pghost60 -h pghost60 \
  -p 60000:5433 --net=pg-network --ip 172.72.6.60 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true pg9_13:1.0 \
  /usr/sbin/init

# 从库
docker run -d --name pghost61 -h pghost61 \
  -p 60001:5433 --net=pg-network --ip 172.72.6.61 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true pg9_13:1.0 \
  /usr/sbin/init
# 远程登录
psql -U postgres -h 192.168.1.100 -p 60000
psql -U postgres -h 192.168.1.100 -p 60001

psql postgresql://postgres:postgres@192.168.1.100:60000/postgres
psql postgresql://postgres:postgres@192.168.1.100:60001/postgres
####################################################################
  