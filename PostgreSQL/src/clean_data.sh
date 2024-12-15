#!/bin/bash


tmp1=`psql -U postgres -Atc "select usename from pg_user where usesysid <> 10"`
tmp2=`psql -U postgres -Atc "select datname from pg_database where datname not in ('postgres','template0','template1')"`
tmp3=`psql -U postgres -Atc "select spcname from pg_tablespace where spcname not in ('pg_default','pg_global')"`


users=($tmp1)
dbs=($tmp2)
tps=($tmp3)

#删除数据库
for ((i=0;i<${#dbs[*]};i++))
do
  psql -U postgres -qc "drop database ${dbs[i]}"
done

#删除表空间
for ((i=0;i<${#tps[*]};i++))
do
  psql -U postgres -qc "drop tablespace ${tps[i]}"
done

#删除用户
for ((i=0;i<${#users[*]};i++))
do
  psql -U postgres -qc "drop user ${users[i]}"
done