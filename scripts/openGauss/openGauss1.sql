--执行计划查看
explain(analyze true,verbose true,costs true,buffers true,timing true,format text)
--根据字段名查询系统表/系统视图
select 
  t2.relname, 
  t1.attname, 
  t3.typname 
from 
  pg_attribute t1 
  join pg_class t2 on t1.attrelid = t2.oid 
  join pg_type t3 on t1.atttypid = t3.oid 
where 
  t1.attname = 'query';

--查看主备同步状态（同步备还是异步备）
select client_addr,client_hostname,sync_state from pg_stat_replication;
--排查是否存在xid不推进问题
select datname,datfrozenxid64 from pg_database;
select relname,relfrozenxid64 from pg_class
where relfrozenxid64::text<>'0'
and relname <> 'pg_%'
order by (relfrozenxid64::text)::int8;
--查询最近的业务表的autovacuum情况
select schemaname,relname,last_vacuum,last_autovacuum
from pg_stat_user_tables
where schemaname='pg_catalog'
order by last_autovacuum desc
nulls last;


--查看Schema下所有表的大小：
select relname, 
	   pg_size_pretty(pg_total_relation_size(relid)) 
from pg_stat_user_tables 
where schemaname='pentaho_dilogs' 
order by pg_relation_size (relid) desc;

--查询数据库中的所有表： 
SELECT         
    pg_catalog.pg_relation_filenode(c.oid) as "Filenode",
    relname as "Table Name"  
FROM     
    pg_class c  
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace  
    LEFT JOIN pg_catalog.pg_database d ON d.datname = 'postgres'      
WHERE     
    relkind IN ('r') 
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    AND n.nspname !~ '^pg_toast'
ORDER BY    
     relname;


--查看当前库sehcma大小,并按schema大小排序
SELECT schema_name, 
    pg_size_pretty(sum(table_size)::bigint) as "disk space",
    round((sum(table_size) / pg_database_size(current_database())) * 100,2)
        as "percent(%)"
FROM (
     SELECT pg_catalog.pg_namespace.nspname as schema_name,
         pg_total_relation_size(pg_catalog.pg_class.oid) as table_size
     FROM   pg_catalog.pg_class
         JOIN pg_catalog.pg_namespace 
             ON relnamespace = pg_catalog.pg_namespace.oid
) t
GROUP BY schema_name
ORDER BY "percent(%)" desc;


--查看当前库中所有表大小,并按降序排列
SELECT
    table_catalog AS database_name,
    table_schema AS schema_name,
    table_name,
    pg_size_pretty(relation_size) AS table_size
FROM (
    SELECT
        table_catalog,
        table_schema,
        table_name,
        pg_total_relation_size(('"' || table_schema || '"."' || table_name || '"')) AS relation_size
    FROM information_schema.tables
    WHERE table_schema not in ('pg_catalog', 'public', 'public_rb', 'topology', 'tiger', 'tiger_data', 'information_schema')
    ORDER BY relation_size DESC
    )
    AS all_tables
WHERE relation_size >= 1073741824;    --筛选大于10GB的表
--查看top10大表
select relname,
		pg_relation_size('public."'||relname||'"') as MB,
		relkind
from pg_class
where relnamespace in
	(select oid
	from pg_namespace
	where nspname not in(
						'pg_toast',
						'pg_temp_1',
						'pg_toast_temp_1',
						'pg_catalog',
						'information_schema'
							))
and relkind='r';



--一直写数据
create table test(date timestamp);
while(true);do gsql -p 12345 -d postgres -r -c 'insert into test values(now())';sleep 3;done

create database testdb;
\c testdb
create user test identified by 'test@123';
grant all privileges to test;
alter database testdb owner to test;

gsql -d testdb -U test -W test@123 -p 12345 -r 

--创建测试表
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
--生成测试数据
insert into employees
select generate_series(1,10000) as key,
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


--插件存放路径
--1、sql文件和control文件
$GAUSSHOME/share/postgresql/extension
--2、so文件
$GAUSSHOME/lib/postgresql

gs_guc reload -N all -I all -c "track_activity_query_size=1200"
gs_guc reload -N all -I all -c "shared_buffers = 128kB"

gs_om -t restart



--创建分区表
CREATE TABLE web_returns_p1
(
    WR_RETURNED_DATE_SK       INTEGER                       ,
    WR_RETURNED_TIME_SK       INTEGER                       ,
    WR_ITEM_SK                INTEGER               NOT NULL,
    WR_REFUNDED_CUSTOMER_SK   INTEGER                       ,
    WR_REFUNDED_CDEMO_SK      INTEGER                       ,
    WR_REFUNDED_HDEMO_SK      INTEGER                       ,
    WR_REFUNDED_ADDR_SK       INTEGER                       ,
    WR_RETURNING_CUSTOMER_SK  INTEGER                       ,
    WR_RETURNING_CDEMO_SK     INTEGER                       ,
    WR_RETURNING_HDEMO_SK     INTEGER                       ,
    WR_RETURNING_ADDR_SK      INTEGER                       ,
    WR_WEB_PAGE_SK            INTEGER                       ,
    WR_REASON_SK              INTEGER                       ,
    WR_ORDER_NUMBER           BIGINT                NOT NULL,
    WR_RETURN_QUANTITY        INTEGER                       ,
    WR_RETURN_AMT             DECIMAL(7,2)                  ,
    WR_RETURN_TAX             DECIMAL(7,2)                  ,
    WR_RETURN_AMT_INC_TAX     DECIMAL(7,2)                  ,
    WR_FEE                    DECIMAL(7,2)                  ,
    WR_RETURN_SHIP_COST       DECIMAL(7,2)                  ,
    WR_REFUNDED_CASH          DECIMAL(7,2)                  ,
    WR_REVERSED_CHARGE        DECIMAL(7,2)                  ,
    WR_ACCOUNT_CREDIT         DECIMAL(7,2)                  ,
    WR_NET_LOSS               DECIMAL(7,2)
)
PARTITION BY RANGE(WR_RETURNED_DATE_SK)
(
        PARTITION P1 VALUES LESS THAN(2450815),
        PARTITION P2 VALUES LESS THAN(2451179),
        PARTITION P3 VALUES LESS THAN(2451544),
        PARTITION P4 VALUES LESS THAN(2451910),
        PARTITION P5 VALUES LESS THAN(2452275),
        PARTITION P6 VALUES LESS THAN(2452640),
        PARTITION P7 VALUES LESS THAN(2453005),
        PARTITION P8 VALUES LESS THAN(MAXVALUE)
);
-- 查看分区表信息
SELECT relname, boundaries, spcname FROM pg_partition p 
JOIN pg_tablespace t 
ON p.reltablespace=t.oid 
and p.parentid='test.web_returns_p1'::regclass 
ORDER BY 1;


--分表总和大小
select 
  tablename, 
  sizeallgb "总大小包含索引GB", 
  sizeallgb2 "表大小GB", 
  sizeallgb - sizeallgb2 "索引大小GB" 
from 
  (
    select 
      regexp_replace(relname, '_\d{1,10}', '', 'g') tablename, 
      round(sum(sizegb),2) sizeallgb, 
      round(sum(sizegb2),2) sizeallgb2 
    from 
      (
        select 
          relname, 
          pg_catalog.pg_total_relation_size(relid)/ 1024  / 1024 sizegb, 
          pg_catalog.pg_relation_size(relid)/ 1024/ 1024 sizegb2 
        from 
          pg_stat_user_tables 
        where 
          regexp_replace(relname, '_\d{1,10}', '', 'g') in ('employees', 'student')
      ) 
    group by 
      regexp_replace(relname, '_\d{1,10}', '', 'g')
  ) 
order by 2 desc;



-- 查询函数信息
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'path';

--获取指定字符串的字节数
SELECT lengthb('hello');
--字符串中的字节数
SELECT octet_length('jose');

--查看数据库编码
select datname,pg_catalog.pg_encoding_to_char(encoding) as encoding
from pg_database;


--查询表存放的位置
select pg_relation_filepath('employees');



-- 查看指定模式下表的元组数、页数、大小等信息
select 
  t2.schemaname, 
  t1.relname, 
  round(pg_total_relation_size(t1.relname::regclass)/ 1024 / 1024, 2) as "total_size/mb", 
  round((pg_total_relation_size(t1.relname::regclass)- pg_relation_size(t1.relname ::regclass))/ 1024/ 1024, 2) as "index_size/mb", 
  t1.relpages, 
  t1.reltuples, 
  t2.n_live_tup, 
  t2.n_dead_tup, 
  t2.last_vacuum, 
  t2.last_autovacuum, 
  t2.last_data_changed 
from 
  pg_class t1 
  join pg_stat_sys_tables t2 on(t1.oid = t2.relid) 
where 
  t2.schemaname = 'pg_catalog' 
  and t1.relkind = 'r';