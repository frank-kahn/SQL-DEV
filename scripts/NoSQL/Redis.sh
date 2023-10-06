#启动redis
ssh redis@192.168.1.185 "/redis/app/bin/redis-server /redis/redis-cluster/node185-7002/redis.conf"
ssh redis@192.168.1.185 "/redis/app/bin/redis-start.sh start"
#停止redis
ssh redis@192.168.1.185 "/redis/app/bin/redis-cli -c -h 192.168.1.185 -p 7002 -a redis shutdown"
pgrep redis-server|xargs kill -9

#连接 redis 集群
redis-cli -c -h 192.168.1.181 -p 7001 -a redis

#创建数据：
set fgkey1 fgedu1
set fgkey2 fgedu2
set fgkey3 fgedu3
set fgkey4 fgedu4
#查询key
get fgkey1
keys *
keys fg*


#获取会话ID
CLIENT ID
#获取当前时间
TIME


#查询集群关系
redis-cli -c -h 192.168.1.181 -p 7001 -a redis cluster nodes
#查询集群详细信息
redis-cli --cluster check 192.168.1.181:7001 -a redis cluster nodes
#查询主节点剪短信息
redis-cli --cluster info 192.168.1.181:7001 -a redis
#集群状态信息
redis-cli -c -h 192.168.1.181 -p 7001 -a redis cluster info


#添加集群节点
#1、添加主节点
redis-cli --cluster add-node 192.168.1.185:7002 192.168.1.181:7001 -a redis
#2、添加从节点
redis-cli --cluster add-node 192.168.1.186:7002 192.168.1.181:7001 --cluster-slave -a redis --cluster-master-id d4cd8261b1ed836a7f44ff2a58d828cff8166c56


#删除集群节点
#1、删除从节点
redis-cli -a redis --cluster del-node 192.168.1.186:7002 40806499734d89db928901fcf048febb71bee2fc
#2、槽位迁移
redis-cli --cluster reshard 192.168.1.181:7001 -a redis
redis-cli -a redis --cluster reshard --cluster-from d4cd8261b1ed836a7f44ff2a58d828cff8166c56 --cluster-to 0b5b7a9e69a61ad17a91f8a20ce93c0544db87b2 --cluster-slots 1366 192.168.1.181:7001
#3、删除主节点
redis-cli -a redis --cluster del-node 192.168.1.186:7002 40806499734d89db928901fcf048febb71bee2fc


