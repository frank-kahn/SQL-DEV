//创建测试数据
use testdb
show collections
for(i=1;i<=1000;i++){
	db.test_user.insertOne({"id":i,"name":"test"+i,"date":new Date()})
	}
db.test_user.find().count();
db.test_user.find().limit(5)

//或者：
use testdb
for(var i = 0; i < 10000; i++) {
	db.test_info.insertOne({x:i, name:"test" + Math.floor(Math.random() * 100), scores : Math.floor(Math.random() * 100)})
	}
db.test_info.find().count();



// testdb.test_t
use testdb
db.test_t.insertOne({id:1,name:'zhangsan'});
db.test_t.insertOne({id:2,name:'lisi'});