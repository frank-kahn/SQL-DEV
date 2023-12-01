#!/bin/bash
sum=0
password=rootroot
sock=/mysql/data/3306/mysql.sock

mysql -uroot -p$password --socket=$sock -se "select distinct table_schema from information_schema.tables where table_schema not in ('information_schema','mysql','performance_schema','sys');" > /tmp/dbname.txt
for i in `cat /tmp/dbname.txt`;do
   tabs=`mysql -uroot -p$password --socket=$sock -se "show tables from $i"|wc -l`
   printf "%-30s%-6d\n" $i $tabs
   sum=$((sum+tabs))
done
printf "%-30s%-6d\n" "表总个数为：" $sum