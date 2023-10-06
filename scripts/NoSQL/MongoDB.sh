#启动
/mongodb/apps/mongodb/bin/mongod --config /mongodb/data/mongo.conf
#关闭服务
/mongodb/apps/mongodb/bin/mongod --config /mongodb/data/mongo.conf -shutdown
#查看日志
tail -100f /mongodb/logs/mongodb.log 

#连接
/mongodb/apps/mongosh/bin/mongosh mongodb://192.168.1.190:27017
mongosh 192.168.1.190:27017
#认证
use admin
db.auth("root","rootroot")

mongosh 192.168.1.191:27017 -u root -p rootroot




#常用命令
#查看当前的数据库
show dbs/show databases
#切换数据库（没有数据的话切换就会创建数据库）
use admin
#查看有哪些表
show tables /show collections
#查看数据库版本信息
db.version();
#查看集群状态
rs.status()
#查看集群的拓扑结构
rs.isMaster()

#创建数据库和表
use fgedudb
db.createCollection("fgeduinfo")
#插入数据就是创建表
db.fgedut01.insertOne({"itpux01":"fgedu01"})
#for循环插入数据
for(var i =0; i <11; i ++){db.fgedut01.insertOne({userName:'itpux'+i,age:i})}
#读表的数据
db.fgedut01.find()
db.fgedut01.find().readPref("secondary")

#从节点加同步锁与解同步锁
db.fsyncLock()
db.fsyncUnlock()
#查看配置情况
rs.config()
#查看主从配置信息
local> db.system.replset.find()
#查询参数信息
use admin
db.adminCommand({getParameter:"*"})
db.adminCommand({getParameter:""})


#节点打标签
conf = rs.conf();
conf.members[0].tags = { "dc": "gz" };
conf.members[1].tags = { "dc": "gz" };
conf.members[2].tags = { "dc": "gz" };
rs.reconfig(conf);
rs.config()


#模拟写大量数据
use fgedudb
show collections
for(i=1;i<=150000;i++){db.fguser.insertOne({"id":i,"name":"fgedunosql"+i})}
db.fguser.find().count();

或者：
use fgedudb
for(var i = 0; i < 10000; i++) {
db.fgeduinfo.insertOne({x:i, name:"fgedunosql" + Math.floor(Math.random() * 100), scores :
Math.floor(Math.random() * 100)})
}
db.fgeduinfo.find().count();


#删除表
db.fgedu01.drop()

use fgedudb
db.dropDatabase();
for(i=1;i<=20000;i++){db.fguser.insertOne({"id":i,"name":"fgedu"+i})}
db.fguser.find().count();
for(i=1;i<=10000;i++){db.fgorder.insertOne({"id":i,"name":"fgorder"+i})}
db.fguser.find().count();
show collections
db.fguser.find().limit(5)
db.fgorder.find().limit(5)

use fgshopdb
show collections
for(i=1;i<=20000;i++){db.fgshop.insertOne({"id":i,"name":"fgshop"+i})}
db.fgshop.find().count();
show collections
db.fgshop.find().limit(5)

