-- 连接数据库
mysql -uroot -prootroot --socket=/mysql/data/3306/mysql.sock

-- MySQL查看某个库下有哪些表
show tables from dbname;

-- 查看tbl_test表中全部的索引信息
show index from tbl_test;

-- 查看有哪些数据库
select schema_name from information_schema.schemata
where schema_name not in ('information_schema','mysql','performance_schema','sys');

-- 查看表的预估数据量（不准确）
select table_schema,table_name,table_rows from information_schema.tables
where table_schema not in ('information_schema','mysql','performance_schema','sys');

-- 查看非系统库表的排序规则
select table_schema,table_name,table_collation from information_schema.tables
where table_schema not in ('information_schema','mysql','performance_schema','sys');

-- 查看非系统库表列的排序规则
select table_schema,table_name,column_name,collation_name from information_schema.columns
where table_schema not in ('information_schema','mysql','performance_schema','sys');


