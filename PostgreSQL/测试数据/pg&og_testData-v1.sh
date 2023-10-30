#!/bin/bash

db_type=PostgreSQL   #输入数据库类型 openGauss/PostgreSQL
db_user=test
db_port=5432


if [ $db_type == "openGauss" ];then
   app="gsql"
else
   app="psql"
fi


$app -d postgres -p $db_port -c "create user $db_user with password 'test@123';"

read -p '请输入想要创建的数据库的个数：' dbs
read -p '请输入每个数据库下要创建的schema的个数：' schs
read -p '请输入每个schema下要创建的表的个数：' tbs
read -p '请输入每个测试表数据的行数：' rows

for i in `seq 1 $dbs`
do
$app -d postgres -p $db_port -c "create database testdb$i with owner=$db_user;"
   for j in `seq 1 $schs`
   do
   $app -d testdb$i -U $db_user -p $db_port -c "create schema test_schema$j;"
      for k in `seq 1 $tbs`
	  do
	  $app -d testdb$i -U $db_user -p $db_port -c "create table test_schema$j.test_t$k(id int,col1 varchar(100));insert into test_schema$j.test_t$k select generate_series(1,$rows),substr(md5(random()::text),1,5);"
	  done
   done
done
