create database testdb;
\c testdb
create user test identified by 'test@123';
grant all privileges to test;
alter database testdb owner to test;


gsql -h192.168.1.61 -d itpuxdb -p 15400 -U itpux -W test_t_12345 

CREATE USER test_t WITH PASSWORD "test_t_12345";
GRANT ALL PRIVILEGES TO test_t;
CREATE DATABASE test_tdb OWNER test_t;
\q

gsql -d itpuxdb -p 15400 -U itpux -W test_t_12345
--创建表
create table test_t(id int ,name varchar(20));
INSERT INTO test_t VALUES (1,'test_t01');
INSERT INTO test_t VALUES (2,'test_t02');
INSERT INTO test_t VALUES (3,'test_t03');
INSERT INTO test_t VALUES (4,'test_t04');
INSERT INTO test_t VALUES (5,'test_t05');
INSERT INTO test_t VALUES (6,'test_t06');
INSERT INTO test_t VALUES (7,'test_t07');
INSERT INTO test_t VALUES (8,'test_t08');
select * from test_t;


\c dbname
set search_path to schemaname ;
create table test_tt(id int ,name varchar(20));
INSERT INTO test_tt VALUES (1,'test_tt02');
INSERT INTO test_tt VALUES (2,'test_tt02');
INSERT INTO test_tt VALUES (3,'test_tt03');
INSERT INTO test_tt VALUES (4,'test_tt04');
INSERT INTO test_tt VALUES (5,'test_tt05');
INSERT INTO test_tt VALUES (6,'test_tt06');
INSERT INTO test_tt VALUES (7,'test_tt07');
INSERT INTO test_tt VALUES (8,'test_tt08');
select * from test_tt;
drop table test_tt;




--插件存放路径
--1、sql文件和control文件
$GAUSSHOME/share/postgresql/extension
--2、so文件
$GAUSSHOME/lib/postgresql

gs_guc reload -N all -I all -c "session_timeout = 86400s"
gs_guc check -N all -I all -c "upgrade_mode"

gs_om -t restart


--查询指定数据库下schema大小（需要先切换到要查询的数据库下） 
SELECT schema_name, 
       round((sum(table_size)::bigint)/1024/1024,2) as "disk space/MB", 
	   round((sum(table_size)/pg_database_size(current_database()))* 100,2) as "percent" 
FROM ( 
       SELECT pg_catalog.pg_namespace.nspname as schema_name, 
	           pg_relation_size(pg_catalog.pg_class.oid) as table_size 
	   FROM pg_catalog.pg_class 
	   JOIN pg_catalog.pg_namespace  
	   on relnamespace = pg_catalog.pg_namespace.oid ) t 
GROUP BY schema_name ORDER BY 2 desc;






1、查看某用户的系统权限 
SELECT * FROM pg_roles WHERE rolname='test';
2、查看某用户的表权限 
select * from information_schema.table_privileges where grantee='test'; 
3、查看某用户的usage权限 
select * from information_schema.usage_privileges where grantee='test'; 
4、查看某用户在存储过程函数的执行权限 
select * from information_schema.routine_privileges where grantee='test'; 
5、查看某用户在某表的列上的权限 
select * from information_schema.column_privileges where grantee='test'; 
6、查看当前用户能够访问的数据类型 
select * from information_schema.data_type_privileges ; 
7、查看用户自定义类型上授予的USAGE权限 
select * from information_schema.udt_privileges where grantee='test';


--pg权限管理
https://blog.csdn.net/eagle89/article/details/112169903


SELECT
    c.relname 表名,
    (current_setting('autovacuum_analyze_threshold')::NUMERIC(12,4))+(current_setting('autovacuum_analyze_scale_factor')::NUMERIC(12,4))*c.reltuples AS 自动分析阈值,
    (current_setting('autovacuum_vacuum_threshold')::NUMERIC(12,4))+(current_setting('autovacuum_vacuum_scale_factor')::NUMERIC(12,4))*c.reltuples AS 自动清理阈值,
    c.reltuples::DECIMAL(19,0) 活元组数1,
    d.n_live_tup 活元组数2,
    d.n_dead_tup::DECIMAL(19,0) 死元组数
FROM
    pg_class c 
JOIN pg_stat_all_tables d
    ON C.relname = d.relname
WHERE
    c.relname = 't_test'  
--	AND c.reltuples > 0
--    AND d.n_dead_tup > (current_setting('autovacuum_analyze_threshold')::NUMERIC(12,4))+(current_setting('autovacuum_analyze_scale_factor')::NUMERIC(12,4))*reltuples;
;



--创建库和用户
create database sysbenchdb dbcompatibility 'B' encoding='utf8';
\c sysbenchdb
create user sysbench password 'test@123';
grant all PRIVILEGES to sysbench;
alter database sysbenchdb owner to sysbench;
--连接数据库
gsql -d sysbenchdb -U sysbench -W test@123 -r






•若max_process_memory-shared_buffers-cstore_buffers-元数据少于2G，openGauss强制把enable_memory_limit设置为off。其中元数据是openGauss内部使用的内存，和部分并发参数，如max_connections，thread_pool_attr，max_prepared_transactions等参数相关。
•当该值为off时，不对数据库使用的内存做限制，在大并发或者复杂查询时，使用内存过多，可能导致操作系统OOM问题。
select * from pg_total_memory_detail;


