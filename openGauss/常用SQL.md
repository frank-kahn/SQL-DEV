# 用户管理

~~~sql
--创建用户
create user test password 'test@123';
create user test identified by 'test@123';
--修改用户密码
alter user oracle identified by oracle;
alter user oracle with password 'Test123~!';
--解锁账户
ALTER USER user_name
    ACCOUNT UNLOCK ;

--查看哪些用户被锁定了 
select b.usename,a.rolstatus,a.locktime 
from pg_user_status a 
join pg_user b on a.roloid=b.usesysid; 

rolstatus 为0表示用户状态正常 
rolstatus 为1表示用户登录失败次数过多（默认10次，受failed_login_attempts参数控制），被锁定一段时间 
rolstatus 为2表示用户被管理员锁定
~~~



# 管理命令

~~~shell
#数据库启停
gs_ctl status/start/stop/restart -D /opt/software/openGauss/data/single_node
gs_om -t status --detail --time-out=1
gs_om -t start/stop/restart

#修改参数
#查询参数
select name,setting,unit,context from pg_settings where name ~ '';
#修改集群参数
gs_guc reload -N all -I all -c "password_encryption_type=1"
gs_guc reload -N all -I all -c "enable_ustore=off"
#修改单节点参数
gs_guc reload -N hostname1 -c "enable_ustore=off"
gs_guc reload -D /home/omm/openGauss-server/dest/dn1 -c "session_timeout = 86400s" 
gs_guc set -D /home/omm/openGauss-server/dest/dn1 -c "session_timeout = 86400s" 
#修改会话参数，第三个参数为true，只应用于当前事务，应用于当前会话，可以使用false，和SQL语句SET是等效的
SELECT set_config('log_statement_stats', 'off', false);

#修改hba文件
gs_guc reload -N all -I all -h "host all all 100.113.130.164/24 sha256"
#取消修改hba文件
gs_guc reload -N all -I all -h "host all all 100.113.130.164/24"

#检查参数值
gsql -d postgres -p 5432 -c 'show shared_buffers' 
gsql -d postgres -p 5432 -c "select name,setting,context from pg_settings where name ~ 'shared_buffers'"
gsql -d postgres -p 5432 -c "select current_setting('shared_buffers')"
gs_guc check -N all -I all -c "password_encryption_type"
gs_ssh -c "gsql -d postgres -p 5432 -c 'show shared_buffers' "




#主备同步相关的参数
select name,setting,unit,context from 
pg_settings where name in 
( 
'synchronous_commit', 
'synchronous_standby_names', 
'most_available_sync', 
'catchup2normal_wait_time', 
'keep_sync_window', 
'wal_sender_timeout' );

#查看是主节点还是备节点
select (case when pg_is_in_recovery()='f' then 'primary' else 'standby' end ) as  primary_or_standby;
select local_role from pg_stat_get_stream_replication();

#查看集群同步备、异步备（主节点查询）
select client_addr,client_hostname,sync_state from pg_stat_replication;

#内存相关参数
select name,setting,unit,context from pg_settings where name in ('max_process_memory','shared_buffers','enable_memory_limit');
+---------------------+---------+------+------------+
|        name         | setting | unit |  context   |
+---------------------+---------+------+------------+
| enable_memory_limit | off     |      | postmaster |
| max_process_memory  | 2097152 | kB   | postmaster |
| shared_buffers      | 91648   | 8kB  | postmaster |
+---------------------+---------+------+------------+
#查询内存的视图（需要修改enable_memory_limit=on）
select * from pg_total_memory_detail;
•若max_process_memory-shared_buffers-cstore_buffers-元数据少于2G，openGauss强制把enable_memory_limit设置为off。其中元>
数据是openGauss内部使用的内存，和部分并发参数，如max_connections，thread_pool_attr，max_prepared_transactions等参数相>
关。
•当该值为off时，不对数据库使用的内存做限制，在大并发或者复杂查询时，使用内存过多，可能导致操作系统OOM问题。




#获取当前事务日志的写入位置（LSN）
select pg_current_xlog_location();
#获取当前事务日志的写入位置，并转换成对应的文件命名格式
select * from pg_xlogfile_name(pg_current_xlog_location());
#pg_controldata工具查看checkpoint位点
pg_controldata $GAUSSDATA

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


#查询连接的sessionid
select pg_current_sessid();
#查看后台进程的pid
select pg_backend_pid();
#数据库启动时间
select pg_postmaster_start_time();

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

#查看数据库编码
select datname,pg_catalog.pg_encoding_to_char(encoding) as encoding
from pg_database;

#查询表存放的本地位置
select pg_relation_filepath('employees');

#查看操作系统块的大小，操作系统页面缓冲区中空闲页面的数量
select * from pgsysconf();
select * from pgsysconf_pretty();
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

# gsql

~~~shell
#提示符设置
cd
cat >.gsqlrc <<EOF
\set PROMPT1 '%n@%~%R%#'
\pset border 2
EOF

#元命令的真实命令 -E
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
-- 内存详细信息查询
select
    b.client_addr,
	b.sessionid,
	a.contextname,
	a.totalsize/1024/1024 totalsize
from gs_session_memory_detail a
     join pg_stat_activity b
	 on b.sessionid=substr(a.sessid,position('.' in a.sessid)+1,100);
~~~

# 对象信息查询

```sql
--查询schema下的对象信息
select t2.nspname as schema_name,
       t3.usename as user,
       t1.relname as object,
       case when t1.relkind = 'r' then 'table'
            when t1.relkind = 'i' then 'index'
            when t1.relkind = 'I' then 'partion_table'
            when t1.relkind = 'S' then 'sequence'
            when t1.relkind = 'v' then 'view'
            when t1.relkind = 'c' then 'compound_type'
            when t1.relkind = 't' then 'TOAST_table'
            when t1.relkind = 'f' then 'foreign_table'
            when t1.relkind = 'm' then 'MaterializedView' end as object_type
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
join pg_user t3 on t1.relowner = t3.usesysid
where 1=1
and t1.relname ~ 'test'
and t2.nspname ~ 'test'
and t3.usename ~ 'test';

--查看数据库信息
SELECT d.datname as "DATABASE",
       pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
       pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
       CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
       END as "Size",
       t.spcname as "Tablespace"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
ORDER BY 1;

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
```

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

## 查看复制槽

~~~shell
select slot_name,coalesce(plugin,'_') as plugin,slot_type,datoid,coalesce(database,'_') as database,
       (case active when 't' then 1 else 0 end)as active,coalesce(xmin,'_') as xmin,dummy_standby,
       pg_xlog_location_diff(CASE WHEN pg_is_in_recovery() THEN restart_lsn ELSE pg_current_xlog_location() END , restart_lsn)  AS delay_lsn
from pg_replication_slots;
~~~

## 查看信息

~~~sql
--主备延迟
--主库
select client_addr,sync_state,pg_xlog_location_diff(pg_current_xlog_location(),receiver_replay_location) from pg_stat_replication;

--备库
select now() AS now, 
       coalesce(pg_last_xact_replay_timestamp(), now()) replay,
       extract(EPOCH FROM (now() - coalesce(pg_last_xact_replay_timestamp(), now()))) AS diff;
       
--主备同步状态（同步备、异步备）
select client_addr,client_hostname,sync_state from pg_stat_replication;
~~~

## 慢SQL

~~~shell
#查看执行计划
explain(analyze true,verbose true,costs true,buffers true,timing true,format text)

select datname,usename,client_addr,pid,query_start::text,extract(epoch from (now() - query_start)) as query_runtime,xact_start::text,extract(epoch from(now() - xact_start)) as xact_runtime,state,query 
from pg_stat_activity 
where state not in('idle') and query_start is not null;

select
db_name,
user_name,
round(db_time/1000,2) as "db_name/ms" ,
start_time,
finish_time,
pg_catalog.statement_detail_decode(details,'plaintext',true)
from statement_history;
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

## session按状态分类所占用内存大小

~~~shell
select state,sum(totalsize)::bigint as totalsize
from gs_session_memory_detail m,pg_stat_activity a 
where substring_inner(sessid,position('.' in sessid) +1)=a.sessionid and usename<>'mondb' and pid != pg_backend_pid() 
group by state order by sum(totalsize) desc;
~~~

## 查看session中query占用内存大小

~~~shell
select sessionid, coalesce(application_name,'')as application_name,
       coalesce(client_addr::text,'') as client_addr,sum(usedsize)::bigint as usedsize, 
       sum(totalsize)::bigint as totalsize,query 
from gs_session_memory_detail s,pg_stat_activity a 
where substring_inner(sessid,position('.' in sessid) +1)=a.sessionid 
group by sessionid,query,application_name,client_addr 
order by sum(totalsize) desc limit 10;
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

# 慢SQL查询

~~~shell
--慢SQL查询
dbe_perf.standby_statement_history(true,'2023-01-01 12:01:01','2023-01-01 12:01:01')
~~~

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

