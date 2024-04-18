#!/bin/bash

result=/tmp/result.txt

#db_num
dbnum=`psql -d postgres -At -c "SELECT count(*) FROM pg_database where datname!='template1' and datname!='template0';"`


#dblist
dbtmp=`psql -d postgres -At -c "SELECT datname FROM pg_database where datname!='template1' and datname!='template0';"`
dblist=($dbtmp)

#tablelist
for ((i=0;i<${#dblist[*]};i++))
do
   tmp$i=`psql -d ${dblist[i]} -At -c "SELECT nspname || '.' || relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema' AND nspname != 'dbe_perf' AND C.relkind <> 'i' AND nspname not like 'pg_toast%' AND nspname != 'dbe_pldeveloper' and nspname != 'db4ai';"`
   tblist$i=(${tmp$i // / })
#   tblist$i=(tmp$i)

done

for ((i=0;i<${#dblist[*]};i++))
do
   for ((j=0;j<$dbnum;j++))
   do
      for ((k=0;k<${#tblist$j[*]};k++))
	  do
      psql -d ${dblist[i]} -At -c "select ${#tblist$j[k]} as tablename,count(*) from ${#tblist$j[k]};" >> $result
      done
   done
done


查询所有的库
gsql -d postgres -p 15100 -r -At -c "SELECT datname FROM pg_database where datname!='template1' and datname!='template0';"
上面查出来的库名保存到一个数组里然后遍历这个数组，用database变量替代，执行下面的命令查询该库所有的表名
gsql -d $database -p -At -c "SELECT nspname || '.' || relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema' AND nspname != 'dbe_perf' AND C.relkind <> 'i' AND nspname !~ '^pg_toast' AND nspname != 'dbe_pldeveloper' and nspname != 'db4ai';"
连到对应的库中查询每个表对应的数据条数
gsql -d $database -p -At -c "select count(*) from $relname;"



psql -d postgres -At -c "SELECT nspname || '.' || relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema' AND nspname != 'dbe_perf' AND C.relkind <> 'i' AND nspname not like 'pg_toast%' AND nspname != 'dbe_pldeveloper' and nspname != 'db4ai';"


dbtmp=`psql -d postgres -At -c "SELECT datname FROM pg_database where datname!='template1' and datname!='template0';"`
dblist=(${dbtmp// / })

dblist=$(echo $dbtmp|xargs -n1)