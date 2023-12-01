#!/bin/bash

read -p '请输入想要创建的数据库的个数：' dbs
read -p '请输入每个数据库下要创建的表的个数：' tbs

for i in `seq 1 $dbs`
do
mysql -uroot -p$password --socket=$sock -se "create database testdb$i;"
   for j in `seq 1 $tbs`
   do
   mysql -uroot -p$password --socket=$sock -se "create table testdb$i.test_t$j(id int,col1 varchar(100));"
      for k in `seq 1 $(shuf -i 1-100 -n 1)`
	  do
	  mysql -uroot -p$password --socket=$sock -se "insert into testdb$i.test_t$j values($RANDOM,concat('test',$k))"
	  done
   done
done



