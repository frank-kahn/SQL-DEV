create database testdb dbcompatibility 'B' encoding='utf8';
\c testdb
create user test identified by 'test@123';
grant all privileges to test;
alter database testdb owner to test;

gsql -d testdb -p 15400 -U test -W test@123


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


--一直写数据
create table test(date timestamp);
while(true);do gsql -p 12345 -d postgres -r -c 'insert into test values(now())';sleep 3;done





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









•若max_process_memory-shared_buffers-cstore_buffers-元数据少于2G，openGauss强制把enable_memory_limit设置为off。其中元数据是openGauss内部使用的内存，和部分并发参数，如max_connections，thread_pool_attr，max_prepared_transactions等参数相关。
•当该值为off时，不对数据库使用的内存做限制，在大并发或者复杂查询时，使用内存过多，可能导致操作系统OOM问题。
select * from pg_total_memory_detail;










create table employees
    ( employee_id    serial    primary key
    , first_name     varchar2(20)
    , last_name      varchar2(25) constraint     emp_last_name_nn  not null
    , email          varchar2(25) constraint     emp_email_nn  not null
    , phone_number   varchar2(20)
    , hire_date      date         constraint     emp_hire_date_nn  not null
    , job_id         int8         constraint     emp_job_nn  not null
    , salary         number(8,2)
    , commission_pct number(4,2)
    , manager_id     int8
    , department_id  int8
    , constraint     emp_salary_min check (salary > 0) 
    --, constraint     emp_email_uk unique (email)
    ) ;

insert into employees
select generate_series(1,1000) as key,
       substr(md5(random()::text),2,5),
       substr(md5(random()::text),2,8),
	   substr(md5(random()::text),2,5)||'@163.com',
	   concat('1',ceiling(random()*9000000000+1000000000)),
	   (random()*(2022-1990)+1990)::int||'-'||(random()*(12-1)+1)::int||'-'||(random()*(28-1)+1)::int,
	   (random()*(50-10)+10)::int,
	   (random()*(10000-3000)+3000)::number(8,2),
	   (random()*(1-0)+0)::number(4,2),
	   (random()*(100-1)+1)::int,
	   (random()*(10-1)+1)::int;	


-- 创建分区表

create table test_range_t (id int8,name varchar(100))
partition by range(id)
(
	partition p1 values less than(1000),
	partition p2 values less than(2000),
	partition p3 values less than(3000),
	partition p4 values less than(4000),
	partition p5 values less than(5000),
	partition p6 values less than(6000),
	partition p7 values less than(7000),
	partition p8 values less than(maxvalue),
);

-- 插入数据
insert into test_range_t select generate_series(1,8000),substr(md5(random()::text),2,5);






