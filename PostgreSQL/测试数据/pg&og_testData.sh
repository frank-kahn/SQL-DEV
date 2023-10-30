#!/bin/bash

db_type=PostgreSQL   #输入数据库类型 openGauss/PostgreSQL
db_user=test
db_port=5433


if [ $db_type == "openGauss" ];then
   app="gsql"
else
   app="psql"
fi


function create(){
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
}


function list_dbname(){
sql="SELECT datname FROM pg_database where datname!='template1' and datname!='template0';"
echo "当前环境有以下几个数据库："
$app -d postgres -U $db_user -p $db_port -At -c "${sql}"
}


function check_dead(){
param1=$1
sql="SELECT pg_stat_user_tables.relname,pg_stat_user_tables.n_dead_tup,pg_stat_user_tables.n_live_tup,pg_stat_user_tables.n_tup_del,pg_stat_user_tables.n_tup_upd,pg_stat_user_tables.autovacuum_count,pg_stat_user_tables.last_vacuum,pg_stat_user_tables.last_autovacuum,now() as now,pg_class.reltuples FROM pg_stat_user_tables INNER JOIN pg_class ON pg_stat_user_tables.relname = pg_class.relname ORDER BY pg_stat_user_tables.n_dead_tup DESC;"
$app -d $param1 -U $db_user -p $db_port -c "${sql}"
}

function update(){
sql="SELECT datname FROM pg_database where datname ~ '^testdb'"
all_db=$(psql -d postgres -p ${db_port} -At -c "${sql}")
sql="SELECT nspname || '.' || relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema' AND nspname != 'dbe_perf' AND C.relkind = 'r' AND nspname !~ '^pg_toast' AND nspname != 'dbe_pldeveloper' and nspname != 'db4ai';"
for db in ${all_db[@]}
	do 
	  all_table=`psql -d ${db} -p ${db_port} -At -c "${sql}"`
	  for table in ${all_table[@]}
	  do
	  psql -d $db -p ${db_port} -c "update $table set col1=substr(md5(random()::text),1,5)"
	done
done
}

case $1 in
   create)
     create
     ;;
   list_dbname)
     list_dbname   
     ;;
   check_dead)
	 list_dbname
	 read -p '请输入要查询死元组情况的数据库：' dbname
	 check_dead $dbname
     ;;
   update)	 
     update
	 ;;
   *)
   echo "-----------------------------------------------------"
   echo "create             创建数据库、模式、表"
   echo "list_dbname        查看所有的数据库名称"
   echo "check_dead         查看指定数据库下表的死元组信息"
   echo "update             更新testdb*库下所有的表的数据"
   echo "-----------------------------------------------------"
   ;;
esac;   