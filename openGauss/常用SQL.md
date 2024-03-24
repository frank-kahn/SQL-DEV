# 管理命令

~~~shell
#慢SQL阈值（对应pg_catalog.statement_history的slow_sql_threshold字段）
omm@postgres=#select name,setting,unit,context from pg_settings where name ~ 'log_min_duration_statement';
+----------------------------+---------+------+-----------+
|            name            | setting | unit |  context  |
+----------------------------+---------+------+-----------+
| log_min_duration_statement | 1800000 | ms   | superuser |
+----------------------------+---------+------+-----------+
(1 row)

#慢SQL记录详细程度
omm@postgres=#select name,setting,unit,context from pg_settings where name ~ 'stmt';
+---------------------------+-------------+------+---------+
|           name            |   setting   | unit | context |
+---------------------------+-------------+------+---------+
| enable_stmt_track         | on          |      | sighup  |
| track_stmt_details_size   | 4096        |      | user    |
| track_stmt_parameter      | off         |      | sighup  |
| track_stmt_retention_time | 3600,604800 |      | sighup  |
| track_stmt_session_slot   | 1000        |      | sighup  |
| track_stmt_stat_level     | OFF,L0      |      | user    |
+---------------------------+-------------+------+---------+
(6 rows)

#控制系统视图中query（SQL查询）长度的参数
omm@postgres=#select name,setting,unit,context from pg_settings where name ~ 'track_activity_query_size';
+---------------------------+---------+------+------------+
|           name            | setting | unit |  context   |
+---------------------------+---------+------+------------+
| track_activity_query_size | 1024    |      | postmaster |
+---------------------------+---------+------+------------+
(1 row)
#说明可能还需要调整instr_unique_sql_count参数




#根据字段名查询系统表/系统视图
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
~~~

# 插件

~~~sql
--可用的扩展(gaussdbAppPath/share/postgresql/extension里面有扩展文件的) 
select * from pg_available_extensions;
--已经安装的扩展 
select * from pg_extension; 
\dx
--扩展存放路径： 
--1、sql和control文件： 
cd $GAUSSHOME/share/postgresql/extension 
--2、so文件： 
cd $GAUSSHOME/lib/postgresql
~~~





# 常用数据字典

~~~sql
-- 查询函数信息
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'regexp_replace';
-- 查询某表某列所有项的大小
SELECT pg_size_pretty(pg_column_size("Values")::bigint) valcolsize,"Id","Values" 
FROM mdm.concept 
ORDER BY pg_column_size("Values") DESC;
~~~

# 对象信息查询

## 通过系统线程id查对应的query

~~~shell
#!/bin/bash

source ~/.bashrc

thread_sets=`ps -ef |grep -i gaussdb |grep -v grep|awk -F ' ' '{print $2}'|xargs top -n 1 -bHp |grep -i ' worker'|awk -F ' ' '{print $1}'|tr "\n" ","|sed -e 's/,$/\n/'`

gsql -p 26000 postgres -c "select  pid,lwtid,state,query from pg_stat_activity a,dbe_perf.thread_wait_status s where a.pid=s.tid and lwtid in($thread_sets);"
~~~

## 查看hang住SQL的堆栈信息

~~~sql
--查sql对应的线程id（lwtid）
select pid,lwtid,state,query from pg_stat_activity a,dbe_perf.thread_wait_status s where a.pid=s.tid and query like '%xxx%';

--查线程的堆栈信息
pstack lwtid
~~~

## 查看当前数据库下所有表的注释信息

~~~shell
\dt+

或

select current_database(),nspname as schema ,relname,description
from pg_class c ,pg_namespace n,pg_description d
where c.relnamespace=n.oid 
and c.oid=d.objoid 
and d.objsubid=0 
and nspname not in('pg_catalog','db4ai');


\d+

或

select current_database(),nspname as schema ,relname,attname as column ,atttypid::regtype as datatype,objsubid,atthasdef as default,description
from pg_class c ,pg_namespace n,pg_attribute a,pg_description d
where c.relnamespace=n.oid 
and a.attrelid=c.oid 
and c.oid=d.objoid 
and a.attnum>0 
and d.objsubid=0 
and nspname not in('pg_catalog','db4ai');
~~~







## 锁阻塞信息

~~~shell
with tl as (select usename,granted,locktag,query_start,query 
            from pg_locks l,pg_stat_activity a 
            where l.pid=a.pid and locktag in(select locktag from pg_locks where granted='f')) 
select ts.usename locker_user,ts.query_start locker_query_start,ts.granted locker_granted,ts.query locker_query,tt.query locked_query,tt.query_start locked_query_start,tt.granted locked_granted,tt.usename locked_user,extract(epoch from now() - tt.query_start) as locked_times
from (select * from tl where granted='t') as ts,(select * from tl where granted='f') tt 
where ts.locktag=tt.locktag 
order by 1;
~~~

## 锁阻塞统计

~~~设立
with tl as (select usename,granted,locktag,query_start,query 
            from pg_locks l,pg_stat_activity a 
            where l.pid=a.pid and locktag in(select locktag from pg_locks where granted='f')) 
select usename,query_start,granted,query,count(query) count 
from tl 
where granted='t' 
group by usename,query_start,granted,query 
order by 5 desc;
~~~

## 数据表大小排序

~~~shell
SELECT CURRENT_CATALOG AS datname,nsp.nspname,rel.relname,
             pg_total_relation_size(rel.oid)       AS bytes,
             pg_relation_size(rel.oid)             AS relsize,
             pg_indexes_size(rel.oid)              AS indexsize,
             pg_total_relation_size(reltoastrelid) AS toastsize
FROM pg_namespace nsp JOIN pg_class rel ON nsp.oid = rel.relnamespace
WHERE nspname NOT IN ('pg_catalog', 'information_schema','snapshot') AND rel.relkind = 'r'
order by 4 desc limit 100; 
~~~

## 索引大小排序

~~~shell
select CURRENT_CATALOG AS datname,schemaname schema_name,relname table_name,indexrelname index_name,pg_table_size(indexrelid) as index_size 
from pg_stat_user_indexes 
where schemaname not in('pg_catalog', 'information_schema','snapshot')
order by 4 desc limit 100;
~~~

## 表膨胀率排序

~~~shell
select CURRENT_CATALOG AS datname,schemaname,relname,n_live_tup,n_dead_tup,round((n_dead_tup::numeric/(case (n_dead_tup+n_live_tup) when 0 then 1 else (n_dead_tup+n_live_tup) end ) *100),2) as dead_rate
from pg_stat_user_tables
where (n_live_tup + n_dead_tup) > 10000
order by 5 desc limit 100;
~~~

## 分表汇总大小



~~~sql
-- 分表如下
test@testdb=>select relname from pg_class where relname ~ 'employees' and relkind = 'r';
+-------------+
|   relname   |
+-------------+
| employees_1 |
| employees_2 |
| employees_3 |
| employees_5 |
| employees_6 |
+-------------+


-- 统计分表的总大小
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
          pg_catalog.pg_total_relation_size(relid)/ 1024 / 1024 / 1024 sizegb, 
          pg_catalog.pg_relation_size(relid)/ 1024 / 1024 / 1024 sizegb2 
        from 
          pg_stat_user_tables 
        where 
          regexp_replace(relname, '_\d{1,10}', '', 'g') in ('employees', 'student')
      ) 
    group by 
      regexp_replace(relname, '_\d{1,10}', '', 'g')
  ) 
order by 2 desc;


-- 统计效果如下
+-----------+------------------+----------+------------+
| tablename | 总大小包含索引GB    | 表大小GB  | 索引大小GB |
+-----------+------------------+----------+------------+
| employees |             7.30 |     6.02 |       1.28 |
+-----------+------------------+----------+------------+
~~~



# 案例

## 拼SQL删除schema下的对象

### 构造测试数据

| 对象类型 | 对象名称                    | 备注 |
| -------- | --------------------------- | ---- |
| 表       | test_t <br>test_s           |      |
| 索引     | test_i                      |      |
| 约束     | nn                          |      |
| 视图     | test_v                      |      |
| 物化视图 | test_mv                     |      |
| 函数     | test_fun<br>tri_insert_func |      |
| 存储过程 | test_pro                    |      |
| 同义词   | test_t1                     |      |
| 序列     | test_seq                    |      |
| 触发器   | insert_trigger              |      |



~~~sql
create table test_t(id serial,name text);
create table test_s(id int,name text);
create index test_i on test_t(id);
alter table test_t add constraint nn check(name is not null);
create view test_v as select * from test_t;
create materialized view test_mv as select * from test_t;

create function test_fun
 returns void as $$
 begin
 return;
 end;
 $$
 language plpgsql;

create or replace procedure test_pro(out p1 int)
as
begin
	select count(*) into p1 from test;
end
/

create or replace synonym test_t1 for test_t;
create sequence test_seq;


CREATE OR REPLACE FUNCTION tri_insert_func() RETURNS TRIGGER AS
$$
DECLARE
BEGIN
        INSERT INTO test_s VALUES(NEW.id1, NEW.id2, NEW.id3);
        RETURN NEW;
END
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER insert_trigger
 BEFORE INSERT ON test_t
 FOR EACH ROW
 EXECUTE PROCEDURE tri_insert_func();
~~~

### 数据字典

~~~sql
--表、索引、约束、视图、物化视图、序列、触发器
select 
  --n.nspname as "schema",
  c.relname as "name",
  case c.relkind when 'r' then 'table' 
                 when 'v' then 'view' 
                 when 'i' then 'index' 
                 when 'I' then 'global partition index' 
                 when 'S' then 'sequence' 
                 when 'l' then 'large sequence'
                 when 'f' then 'foreign table' 
                 when 'm' then 'materialized view'  
                 when 'e' then 'stream' 
                 when 'o' then 'contview' end as "object_type"
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public';

--约束
select --n.nspname
	   t.conname,
	  'constraint'	    
from pg_constraint t
join pg_catalog.pg_namespace n on n.oid = t.connamespace
where n.nspname='public';

--同义词
select --n.nspname
	   t1.synname,
	  'synonym'	    
from pg_synonym t1
join pg_catalog.pg_namespace n on n.oid = t1.synnamespace
where n.nspname='public';

--函数、存储过程
select --n.nspname,
	   t2.proname,
	   case t2.prokind when 'f' then 'function' 
                       when 'p' then 'procedure' end  	    
from pg_proc t2
join pg_catalog.pg_namespace n on n.oid = t2.pronamespace
where n.nspname='public';

--触发器
select tgname from pg_trigger;
~~~

### 拼drop_sql

~~~sql
with obj_info as(
-- 表、索引、约束、视图、物化视图、序列、触发器
-- 表删除了，表上的索引、约束、触发器都会自动删除
select 
  --n.nspname as "schema",
  c.relname as "name",
  case c.relkind when 'r' then 'table' 
                 when 'v' then 'view' 
                 when 'i' then 'index' 
                 when 'I' then 'global partition index' 
                 when 'S' then 'sequence' 
                 when 'l' then 'large sequence'
                 when 'f' then 'foreign table' 
                 when 'm' then 'materialized view'  
                 when 'e' then 'stream' 
                 when 'o' then 'contview' end as "object_type"
from pg_catalog.pg_class c
join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
union all
-- 同义词
select --n.nspname
	   t1.synname,
	  'synonym'	    
from pg_synonym t1
join pg_catalog.pg_namespace n on n.oid = t1.synnamespace
where n.nspname='public'		
union all
-- 函数、存储过程
select --n.nspname,
	   t2.proname,
	   case t2.prokind when 'f' then 'function' 
                       when 'p' then 'procedure' end  	    
from pg_proc t2
join pg_catalog.pg_namespace n on n.oid = t2.pronamespace
where n.nspname='public'
	)
select 
	case object_type when 'function' then $$drop $$||object_type||$$ if exists $$||name||$$;$$ 
                     when 'procedure' then $$drop $$||object_type||$$ if exists $$||name||$$;$$
                     else $$drop $$||object_type||$$ if exists $$||name||$$ cascade;$$ end as drop_sql
from obj_info;
~~~



效果

~~~sql
                     drop_sql
---------------------------------------------------
 drop index if exists test_i cascade;
 drop view if exists test_v cascade;
 drop sequence if exists test_t_id_seq cascade;
 drop table if exists test_s cascade;
 drop materialized view if exists test_mv cascade;
 drop sequence if exists test_seq cascade;
 drop table if exists test_t cascade;
 drop synonym if exists test_t1 cascade;
 drop function if exists test_fun;
 drop procedure if exists test_pro;
 drop function if exists tri_insert_func;
(11 rows)

testdb=#
~~~

## 游标遍历删除指定表上的索引

~~~sql
declare
   sql1 text;
   sql2 text;
--普通索引
   CURSOR cur for (select tablename,indexname from pg_indexes where tablename ~ 'sbtest' and indexname !~ 'pkey$');
--主键
   CURSOR cur_pk for (select tablename from pg_indexes where tablename ~ 'sbtest' and indexname ~ 'pkey$');
BEGIN
--删除主键索引
   for recordvar1 in cur_pk LOOP
   sql1=concat('alter table ',recordvar1.tablename,' drop primary key;');
   EXECUTE sql1;
   end loop;
--删除普通索引   
   for recordvar2 in cur LOOP
   sql1=concat('drop index ',recordvar2.indexname,' on ',recordvar2.tablename,';');
   EXECUTE sql1;
   end loop;   
end
/
~~~

## 动态sql

~~~shell
--动态SQL拼接
create table test (id int) comment 'testdfasdfasdfasdfasdf'; 
DO $$ <<test_text>> 
DECLARE 
txt text := md5(random()::varchar); 
tet text := md5(random()::varchar);
cnt integer := 0;
test_sql text;
BEGIN
while cnt<10 loop 
tet :=tet||txt;
cnt := cnt + 1;
end loop;
drop table if exists test;
test_sql :='create table test (id int) comment '||''''||tet||''''||';'; 
raise notice '拼接的SQL：% ',test_sql;
execute immediate test_sql; 
END test_text $$;
~~~

## prepare语句

~~~
--prepare语句
create table test(id int);
prepare s(int) as insert into test values($1);
EXECUTE s(1);
~~~

## copy命令

~~~shell
--创建测试表
create table test(id bigserial,col1 text,col2 text);
--copy的文件如下：
vi data
tabo	 tabo
gvum	 gvum
pohv	 pohv
okgv	 okgv
dsgh	 dsgh
rbwv	 rbwv
dopy	 dopy
cysd	 cysd
ppyy	 ppyy
lrzg	 lrzg
phkk	 phkk
aulp	 aulp
mkyp	 mkyp
ucug	 ucug
nouu	 nouu
vase	 vase
khga	 khga
surh	 surh
ngec	 ngec
rmbe	 rmbe

--copy命令：
copy test(col1,col2) FROM '/data/yaokang/data' ;
copy test(col1,col2) FROM '/data/yaokang/data'  WITH (format 'text', delimiter E'\t', ignore_extra_data 'true', noescaping 'true');

--总结
copy的时候不用考虑序列列，指定其他列就可以
~~~



# CM组件命令

~~~shell
#启停数据库
cm_ctl start/stop
#启停指定的节点
cm_ctl start/stop -n 节点ID
#查看集群状态
cm_ctl query -Cvdip
#查看配置文件信息
cm_ctl view
#主备切换
cm_ctl switchover -n 2 -D /data/cluster/dn
cm_ctl switchover -n 3 -D /data/cluster/dn
cm_ctl switchover -n 1 -D /data/cluster/dn
#切换当前节点为主节点
cm_ctl switchover -a

#gs_om主备切换
#连接到想要升主的主机上 
gs_ctl switchover -D /gauss/gaussdb/data/dn 
#查询集群状态 
gs_om -t status --detail 
#刷新配置文件 
gs_om -t refreshconf


#重新设置log日志位置
cmserver_log=/data/cluster/gaussdb_log/omm/cm/cm_server
cmagent_log=/data/cluster/gaussdb_log/omm/cm/cm_agent
cm_ctl set --param --server -k log_dir="'${cmserver_log}'"
cm_ctl set --param --agent -k log_dir="'${cmagent_log}'"
~~~

# 统计信息相关命令

~~~sql
-- 表清理收缩
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
~~~

[(80条消息) postgresql数据库 查询慢的原因之一（死元祖太多） postgresql表清理收缩_yang_z_1的博客-CSDN博客_postgres 死元组](https://blog.csdn.net/yang_z_1/article/details/115716901)

# 并发创建索引

~~~shell
--并发创建索引
alter table t1 set (parallel_workers=6);
~~~

# 其他

~~~shell
--获取数据库级的全量SQL(Full SQL)信息
select * from dbe_perf.get_global_full_sql_by_timestamp(start_timestamp timestamp with time zone, end_timestamp timestamp with time zone);
--查看redo是否结束
select redo_finished read_disable_conn_file();
--主备同步相关的参数
select name,setting,unit,context from 
pg_settings where name in 
( 
'synchronous_commit', 
'synchronous_standby_names', 
'most_available_sync', 
'catchup2normal_wait_time', 
'keep_sync_window', 
'wal_sender_timeout' );
--gs_dump 导出指定库的指定schema的对象（不包含数据）
gs_dump -f paas.sql -p 17700 database -n schema -F p -x -O -s
~~~

# xid问题

~~~shell
--排查是否存在xid不推进问题
select datname,datfrozenxid64 from pg_database;

select relname,relfrozenxid64 from pg_class
where relfrozenxid64::text<>'0'
and relname <> 'pg_%'
order by (relfrozenxid64::text)::int8;
~~~

# autovacuum情况

~~~shell
--查询最近的业务表的autovacuum情况
select schemaname,relname,last_vacuum,last_autovacuum
from pg_stat_user_tables
where schemaname='pg_catalog'
order by last_autovacuum desc
nulls last;
~~~

# 对象管理

## 分区表

~~~shell
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
~~~



# 常用`SQL`



## 统计表行数

```sql
SELECT
    schemaname as table_schema, relname as table_name, n_live_tup as row_count
FROM
    pg_stat_user_tables
ORDER BY
    n_live_tup DESC;
    
select table_schema, 
       table_name, 
       (xpath('/row/cnt/text()', xml_count))[1]::text::int as row_count
from (
  select table_name, table_schema, 
         query_to_xml(format('select count(*) as cnt from %I.%I', table_schema, table_name), false, true, '') as xml_count
  from information_schema.tables
  where table_schema = 'public' --<< change here for the schema you want
) t order by 3 DESC
```





## 死元组数量查询

![](D:\我的资料\database\openGauss\images\死元组数量查询SQL.jpg)

```sql
=> CREATE FUNCTION get_value(param text, reloptions text[], relkind "char")
RETURNS float
AS $$
  SELECT coalesce(
    -- if the storage parameter is set, we take its value
    (SELECT option_value
     FROM   pg_options_to_table(reloptions)
     WHERE  option_name = CASE
              -- for TOAST tables, the parameter name differs
              WHEN relkind = 't' THEN 'toast.' ELSE ''
            END || param
    ),
    -- otherwise, we take the value of the configuration parameter
    current_setting(param)
  )::float;
$$ LANGUAGE sql;
And this is the view:


=> CREATE VIEW need_vacuum AS
  SELECT st.schemaname || '.' || st.relname tablename,
         st.n_dead_tup dead_tup,
         get_value('autovacuum_vacuum_threshold', c.reloptions, c.relkind) +
         get_value('autovacuum_vacuum_scale_factor', c.reloptions, c.relkind) * c.reltuples
         max_dead_tup,
         st.last_autovacuum
  FROM   pg_stat_all_tables st,
         pg_class c
  WHERE  c.oid = st.relid
  AND    c.relkind IN ('r','m','t');
  
  => CREATE VIEW need_analyze AS
  SELECT st.schemaname || '.' || st.relname tablename,
         st.n_mod_since_analyze mod_tup,
         get_value('autovacuum_analyze_threshold', c.reloptions, c.relkind) +
         get_value('autovacuum_analyze_scale_factor', c.reloptions, c.relkind) * c.reltuples
         max_mod_tup,
         st.last_autoanalyze
  FROM   pg_stat_all_tables st,
         pg_class c
  WHERE  c.oid = st.relid
  AND    c.relkind IN ('r','m');
```



## 膨胀

### 查看表膨胀

```shell
SELECT
  current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,
  ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,
  CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::bigint || $$ bytes$$ END AS wastedsize,
  iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,
  ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::bigint || $$ bytes$$ END AS wastedisize,
  CASE WHEN relpages < otta THEN
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END
    ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)
      ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END
  END AS totalwastedbytes
FROM (
  SELECT
    nn.nspname AS schemaname,
    cc.relname AS tablename,
    COALESCE(cc.reltuples,0) AS reltuples,
    COALESCE(cc.relpages,0) AS relpages,
    COALESCE(bs,0) AS bs,
    COALESCE(CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,
    COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM
     pg_class cc
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$
  LEFT JOIN
  (
    SELECT
      ma,bs,foo.nspname,foo.relname,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        ns.nspname, tbl.relname, hdr, ma, bs,
        SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,
        MAX(coalesce(null_frac,0)) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname
        ) AS nullhdr
      FROM pg_attribute att 
      JOIN pg_class tbl ON att.attrelid = tbl.oid
      JOIN pg_namespace ns ON ns.oid = tbl.relnamespace 
      LEFT JOIN pg_stats s ON s.schemaname=ns.nspname
      AND s.tablename = tbl.relname
      AND s.inherited=false
      AND s.attname=att.attname,
      (
        SELECT
          (SELECT current_setting($$block_size$$)::numeric) AS bs,
            CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)
              IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      WHERE att.attnum > 0 AND tbl.relkind=$$r$$
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  ON cc.relname = rs.relname AND nn.nspname = rs.nspname
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml order by wastedbytes desc limit 5
```



### 查看索引膨胀

```shell
SELECT
  current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,
  ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,
  CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::bigint || $$ bytes$$ END AS wastedsize,
  iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,
  ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::bigint || $$ bytes$$ END AS wastedisize,
  CASE WHEN relpages < otta THEN
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END
    ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)
      ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END
  END AS totalwastedbytes
FROM (
  SELECT
    nn.nspname AS schemaname,
    cc.relname AS tablename,
    COALESCE(cc.reltuples,0) AS reltuples,
    COALESCE(cc.relpages,0) AS relpages,
    COALESCE(bs,0) AS bs,
    COALESCE(CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,
    COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM
     pg_class cc
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$
  LEFT JOIN
  (
    SELECT
      ma,bs,foo.nspname,foo.relname,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        ns.nspname, tbl.relname, hdr, ma, bs,
        SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,
        MAX(coalesce(null_frac,0)) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname
        ) AS nullhdr
      FROM pg_attribute att 
      JOIN pg_class tbl ON att.attrelid = tbl.oid
      JOIN pg_namespace ns ON ns.oid = tbl.relnamespace 
      LEFT JOIN pg_stats s ON s.schemaname=ns.nspname
      AND s.tablename = tbl.relname
      AND s.inherited=false
      AND s.attname=att.attname,
      (
        SELECT
          (SELECT current_setting($$block_size$$)::numeric) AS bs,
            CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)
              IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      WHERE att.attnum > 0 AND tbl.relkind=$$r$$
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  ON cc.relname = rs.relname AND nn.nspname = rs.nspname
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml order by wastedibytes desc limit 5
```



## 常用视图

### `pg_indexes`

> - **schemaname:** stores the name of the schema that contains tables and indexes.
> - **tablename:** stores name of the table to which the index belongs.
> - **indexname:** stores name of the index.
> - **tablespace:** stores name of the tablespace that contains indexes.
> - **indexdef:** stores index definition command in the form of CREATE INDEX statement.
>
> **Example 1:**
>
> The following statement lists all indexes of the schema public in the current database:
>
> ```
> SELECT
>     tablename,
>     indexname,
>     indexdef
> FROM
>     pg_indexes
> WHERE
>     schemaname = 'public'
> ORDER BY
>     tablename,
>     indexname;
> ```
>
> **Example 2:**
>
> The following statement lists all the indexes for the *customer* table, you use the following statement:
>
> ```
> SELECT
>     indexname,
>     indexdef
> FROM
>     pg_indexes
> WHERE
>     tablename = 'customer';
> ```

## `SQL大全`

```sql
# 获取锁信息
with    
t_wait as    
(    
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,    
b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted   
),   
t_run as   
(   
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,   
b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted   
),   
t_overlap as   
(   
  select r.* from t_wait w join t_run r on   
  (   
    r.locktype is not distinct from w.locktype and   
    r.database is not distinct from w.database and   
    r.relation is not distinct from w.relation and   
    r.page is not distinct from w.page and   
    r.tuple is not distinct from w.tuple and   
    r.virtualxid is not distinct from w.virtualxid and   
    r.transactionid is not distinct from w.transactionid and   
    r.classid is not distinct from w.classid and   
    r.objid is not distinct from w.objid and   
    r.objsubid is not distinct from w.objsubid and   
    r.pid <> w.pid   
  )    
),    
t_unionall as    
(    
  select r.* from t_overlap r    
  union all    
  select w.* from t_wait w    
)    
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,   
string_agg(   
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||   
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||   
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||    
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||    
'SQL (Current SQL in Transaction): '||chr(10)||  
case when query is null then 'NULL' else query::text end,    
chr(10)||'--------'||chr(10)    
order by    
  (  case mode    
    when 'INVALID' then 0   
    when 'AccessShareLock' then 1   
    when 'RowShareLock' then 2   
    when 'RowExclusiveLock' then 3   
    when 'ShareUpdateExclusiveLock' then 4   
    when 'ShareLock' then 5   
    when 'ShareRowExclusiveLock' then 6   
    when 'ExclusiveLock' then 7   
    when 'AccessExclusiveLock' then 8   
    else 0   
  end  ) desc,   
  (case when granted then 0 else 1 end)  
) as lock_conflict  
from t_unionall   
group by   
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;

# 获取数据库大小 
select pg_size_pretty(pg_database_size('db1'));


SELECT sender_flush_location,receiver_replay_location from pg_catalog.pg_stat_get_wal_senders() where peer_role != 'Secondary';

show enable_bitmapscan;
select current_timestamp, pg_postmaster_start_time(),current_timestamp-pg_postmaster_start_time() ; # 数据库启动时间
select pg_is_in_recovery() ; # 查看是否为主
show max_process_memory; # 最大可用内存
# show shared_buffers ;
# 内存相关
select * from gs_total_memory_detail ;
select * from pg_total_memory_detail ; # 内存分布情况
select contextname,sum(totalsize)/1024/1024 sum ,sum(freesize)/1024/1024 ,count(*) count from gs_session_memory_detail group by contextname order by sum desc limit 10; # 会话内存相关
select count(*),state from pg_stat_activity group by state ; # 会话状态 
select sum(totalsize)/1024/1024 as sum from gs_session_memory_detail group by sessid order by sum desc ; # 会话内存相关
select * from dbe_perf.statement_history -- 记录慢SQL
log_min_duration_statement
# 参数说明： 当某条语句的持续时间大于或者等于特定的毫秒数时，log_min_duration_statement参数用于控制记录每条完成语句的持续时间。
设置log_min_duration_statement可以很方便地跟踪需要优化的查询语句。对于使用扩展查询协议的客户端，语法分析、绑定、执行每一步所花时间被独立记录。
指定该参数的值可以设置慢sql的抓取阈值，例如：
gs_ctl reload -I all -N all -c"log_min_duratuion_statement=20ms" 
该语句表示把集群内所有节点的log_min_duratuion_statement参数都设置为20ms，这时候执行时间超过20ms的sql都被定义为慢sql，并被记录到dbe_perf.statement_history这个表中。
该表会记录sql的详细信息，执行时间，cpu时间，解析时间等等,需要注意的是该表只在主库可读，备库没有该表。该表中的信息保留时间默认为7天，保留时间收参数track_stmt_retention_time的影响。
track_stmt_retention_time
参数说明： 组合参数，控制全量/慢SQL记录的保留时间。以60秒为周期读取该参数，并执行清理超过保留时间的记录，仅sysadmin用户可以访问。
该参数属于SIGHUP类型参数，请参考表1中对应设置方法进行设置。
取值范围： 字符型
该参数分为两部分，形式为’full sql retention time, slow sql retention time’
full sql retention time为全量SQL保留时间，取值范围为0 ~ 86400
slow sql retention time为慢SQL的保留时间，取值范围为0 ~ 604800
默认值： 3600,604800
该参数的值单位为秒，全量sql的保留时间默认为一小时，慢sql默认保留七天，如果慢sql的量比较大，建议修改慢sql的保留时间为两天或者一天。
gs_guc set -I all -N all -c"track_stmt_retention_time='3600,172800'"
如上语句为设置全量sql保留1小时，慢sql保留两天。

select * from dbe_perf.statement  -- 记录所有SQL
select * from DBE_PERF.get_global_full_sql_by_timestamp('2020-12-01 09:25:22', '2020-12-31 23:54:41'); # 查看SQL语句执行信息
select * from pg_releation_filenode("tablename") #查询表对应的ID号
select * from heap_page_items(get_raw_page('hot_test',0))
select generate_series(1, 1000000000000000);  # 快速生成大表测试数据
select g, md5(g::text), random() * 100, random() * 1000 from generate_series(1, 10000000) g;
postgres=# create table test (id int,info text);
postgres=# insert into test select generate_series(1,100000),'digoal'||generate_series(1,100000);

digoal=# create table tbl_cost_align (id int, info text, crt_time timestamp);
digoal=# insert into tbl_cost_align select (random()*2000000000)::int, md5(random()::text), clock_timestamp() from generate_series(1,100000);

create table tbl_user_info (userid int8 primary key, pwd text);
insert into tbl_user_info select generate_series(1,10000000), md5(clock_timestamp()::text);

select * from pg_class where oid='t1'::regclass;
select datname,pg_size_pretty(pg_database_size(datname)) from pg_database; # 各个数据库大小
select pg_total_relation_size('public.table1'); # 表table1使用的总磁盘空间
select table_distribution('public','table1');# 表table1在各个DN上占用的存储空间
select sessionid, block_sessionid from pg_thread_wait_status; # 查看session之间的阻塞关系
select sessionid, block_sessionid from DBE_PERF.local_active_session; # 采样blocking session信息
select sessionid, block_sessionid, final_block_sessionid from DBE_PERF.local_active_session; # Final blocking session展示
# 最耗资源的wait event
SELECT s.type, s.event, t.count
FROM dbe_perf.wait_events s, (
SELECT event, COUNT(*)
FROM dbe_perf.local_active_session
WHERE sample_time > now() - 5 / (24 * 60)
GROUP BY event)t WHERE s.event = t.event ORDER BY count DESC;

# 查看最近五分钟较耗资源的session把资源都花费在哪些event上
SELECT sessionid, start_time, event, count
FROM (
SELECT sessionid, start_time, event, COUNT(*)
FROM dbe_perf.local_active_session
WHERE sample_time > now() - 5 / (24 * 60)
GROUP BY sessionid, start_time, event) as t ORDER BY SUM(t.count) OVER (PARTITION BY t.
sessionid, start_time)DESC, t.event;

# 最近五分钟比较占资源的SQL把资源都消耗在哪些event上
SELECT query_id, event, count
FROM (
SELECT query_id, event, COUNT(*)
FROM dbe_perf.local_active_session
WHERE sample_time > now() - 5 / (24 * 60)
GROUP BY query_id, event) t ORDER BY SUM(t.count) OVER (PARTITION BY t.query_id ) DESC,
t.event DESC;
select * from pg_node_env ;  #查询数据库节点信息
select pg_get_viewdef('v1'); # 获取视图定义 
 
 # 查询分区表信息
 select p.relname,c.relname from pg_partition p,pg_class c where p.parentid=c.oid;
 SELECT t1.oid, t1.relname, partstrategy, boundaries, t1.reltablespace, t1.parentid FROM pg_partition t1, pg_class t2 WHERE t1.parentid = t2.oid AND t2.relname = 'sales' AND t1.parttype = 'p';

SELECT t1.oid, t1.relname, partstrategy, boundaries, t1.reltablespace, t1.parentid postgres-# FROM pg_partition t1, pg_class t2 WHERE t1.parentid = t2.oid AND t2.relname = 'pt_hash' AND t1.parttype = 'p';
SELECT node_name FROM DBE_PERF.node_name;
select pg_current_xlog_location(), pg_xlogfile_name(pg_current_xlog_location()), pg_xlogfile_name_offset(pg_current_xlog_location());  # 获取pgxlog信息

gs_guc check -D %s -c port # 获取端口
gs_om -t view |grep datanodeLocalDataPath|sort|uniq|awk -F: '{print $NF}'
# 主备同步情况
select a.client_addr, b.state, b.sender_sent_location,
                  b.sender_write_location, b.sender_flush_location,
                  b.sender_replay_location, b.receiver_received_location,
                  b.receiver_write_location, b.receiver_flush_location,  
                  b.receiver_replay_location, b.sync_percent, b.sync_state
                  from pg_stat_replication a inner join 
                  pg_stat_get_wal_senders() b on a.pid = b.pid;
				  
# 当前库状态			-- 单主  
postgres=# select local_role, static_connections, db_state from pg_stat_get_stream_replications();
 local_role | static_connections | db_state
------------+--------------------+----------
 Normal     |                  0 | Normal
(1 row)
# 有备的情况
postgres=# select local_role, static_connections, db_state from pg_stat_get_stream_replications();
 local_role | static_connections | db_state
------------+--------------------+----------
 Primary    |                  6 | Normal
(1 row)

# 级联备情况
select state, sender_sent_location, sender_write_location,
                             sender_flush_location, sender_replay_location,
                             receiver_received_location, receiver_write_location,
                             receiver_flush_location, receiver_replay_location,
                             sync_percent, channel from pg_stat_get_wal_receiver();
                             

# 通过系统线程id查对应的query

#!/bin/bash

source ~/.bashrc

thread_sets=`ps -ef |grep -i gaussdb |grep -v grep|awk -F ' ' '{print $2}'|xargs top -n 1 -bHp |grep -i ' worker'|awk -F ' ' '{print $1}'|tr &quot;\n&quot; &quot;,&quot;|sed -e 's/,$/\n/'`

gsql -p 26000 postgres -c "select  pid,lwtid,state,query from pg_stat_activity a,dbe_perf.thread_wait_status s where a.pid=s.tid and lwtid in($thread_sets)"

# 查看复制槽
select slot_name,coalesce(plugin,'_') as plugin,slot_type,datoid,coalesce(database,'_') as database,
       (case active when 't' then 1 else 0 end)as active,coalesce(xmin,'_') as xmin,dummy_standby,
       pg_xlog_location_diff(CASE WHEN pg_is_in_recovery() THEN restart_lsn ELSE pg_current_xlog_location() END , restart_lsn)  AS delay_lsn
from pg_replication_slots;

# 查看主备延迟 
--主库
select client_addr,sync_state,pg_xlog_location_diff(pg_current_xlog_location(),receiver_replay_location) from pg_stat_replication;

--备库
select now() AS now, 
       coalesce(pg_last_xact_replay_timestamp(), now()) replay,
       extract(EPOCH FROM (now() - coalesce(pg_last_xact_replay_timestamp(), now()))) AS diff;

# 慢SQL查询
select datname,usename,client_addr,pid,query_start::text,extract(epoch from (now() - query_start)) as query_runtime,xact_start::text,extract(epoch from(now() - xact_start)) as xact_runtime,state,query 
from pg_stat_activity where state not in('idle') and query_start is not null;

# 锁阻塞详情
with tl as (select usename,granted,locktag,query_start,query 
            from pg_locks l,pg_stat_activity a 
            where l.pid=a.pid and locktag in(select locktag from pg_locks where granted='f')) 
select ts.usename locker_user,ts.query_start locker_query_start,ts.granted locker_granted,ts.query locker_query,tt.query locked_query,tt.query_start locked_query_start,tt.granted locked_granted,tt.usename locked_user,extract(epoch from now() - tt.query_start) as locked_times
from (select * from tl where granted='t') as ts,(select * from tl where granted='f') tt 
where ts.locktag=tt.locktag 
order by 1;

# 锁阻塞源统计
with tl as (select usename,granted,locktag,query_start,query 
            from pg_locks l,pg_stat_activity a 
            where l.pid=a.pid and locktag in(select locktag from pg_locks where granted='f')) 
select usename,query_start,granted,query,count(query) count 
from tl 
where granted='t' 
group by usename,query_start,granted,query 
order by 5 desc;

# 数据表大小排序</h3>
SELECT CURRENT_CATALOG AS datname,nsp.nspname,rel.relname,
             pg_total_relation_size(rel.oid)       AS bytes,
             pg_relation_size(rel.oid)             AS relsize,
             pg_indexes_size(rel.oid)              AS indexsize,
             pg_total_relation_size(reltoastrelid) AS toastsize
FROM pg_namespace nsp JOIN pg_class rel ON nsp.oid = rel.relnamespace
WHERE nspname NOT IN ('pg_catalog', 'information_schema','snapshot') AND rel.relkind = 'r'
order by 4 desc limit 100; 

# 索引大小排序</h3>
select CURRENT_CATALOG AS datname,schemaname schema_name,relname table_name,indexrelname index_name,pg_table_size(indexrelid) as index_size 
from pg_stat_user_indexes 
where schemaname not in('pg_catalog', 'information_schema','snapshot')
order by 4 desc limit 100;

# 表膨胀率排序</h3>
select CURRENT_CATALOG AS datname,schemaname,relname,n_live_tup,n_dead_tup,round((n_dead_tup::numeric/(case (n_dead_tup+n_live_tup) when 0 then 1 else (n_dead_tup+n_live_tup) end ) *100),2) as dead_rate
from pg_stat_user_tables
where (n_live_tup + n_dead_tup) &gt; 10000
order by 5 desc limit 100;

# 按状态分类所占用内存大小
select state,sum(totalsize)::bigint as totalsize
from gs_session_memory_detail m,pg_stat_activity a 
where substring_inner(sessid,position('.' in sessid) +1)=a.sessionid and usename&lt;&gt;'mondb' and pid != pg_backend_pid() 
group by state order by sum(totalsize) desc;

# 查看session中query占用内存大小
select sessionid, coalesce(application_name,'')as application_name,
       coalesce(client_addr::text,'') as client_addr,sum(usedsize)::bigint as usedsize, 
       sum(totalsize)::bigint as totalsize,query 
from gs_session_memory_detail s,pg_stat_activity a 
where substring_inner(sessid,position('.' in sessid) +1)=a.sessionid 
group by sessionid,query,application_name,client_addr 
order by sum(totalsize) desc limit 10;

```

