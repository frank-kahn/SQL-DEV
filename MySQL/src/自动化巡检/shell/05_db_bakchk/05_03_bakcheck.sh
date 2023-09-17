tail -n 10 /mysqlbak/mysql_cjcdb*.sql|grep  -i -E 'fail|error'
head  -n 10 /mysqlbak/mysql_cjcdb*.sql|grep -i -E 'fail|error'
