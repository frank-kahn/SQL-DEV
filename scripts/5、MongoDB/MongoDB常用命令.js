// 三节点shard集群启停
/mongodb/scripts/start-all.sh
/mongodb/scripts/stop-all.sh

// 检查各个节点进程信息
for i in 192.168.1.19{1..3};do
  echo "-------------$i-----------------"
  ssh $i ps ux|grep config|grep -v grep
done

// 检查端口
ps -ef|egrep "mongo.*.conf"|grep -v grep|awk '{print $NF}'|xargs grep -i port


// 连接数据库
mongosh -u root -p rootroot 192.168.1.191:20000/admin

OR:

mongosh 192.168.1.191:20000
use admin
db.auth("root", "rootroot")

// 创建管理用户
use admin
db.createUser(
{
  user: "root",
  pwd: "rootroot",
  roles: [ { role: "root", db: "admin" } ]
}
)

// 业务用户
use testdb
db.createUser(
{
  user: "test_user1",
  pwd: "test",
  roles: [ { role: "readWrite", db: "testdb" } ]
}
)



// MongoDB中remove和drop的区别
remove用于将集合中的文档删除，但不删除集合本身，也不删除集合的索引。
drop不仅删除集合的文档，也会删除集合本身，同时也会删除在集合上创建的索引。