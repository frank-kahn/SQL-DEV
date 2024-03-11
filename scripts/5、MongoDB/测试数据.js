//创建测试数据
use testdb
show collections
for(i=1;i<=150000;i++){
	db.test_user.insertOne({"id":i,"name":"test"+i})
	}
db.test_user.find().count();

//或者：
use testdb
for(var i = 0; i < 10000; i++) {
	db.test_info.insertOne({x:i, name:"test" + Math.floor(Math.random() * 100), scores : Math.floor(Math.random() * 100)})
	}
db.test_info.find().count();

