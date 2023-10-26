

# 常用`SQL`

## 判断当前是否主库

```sql
select pg_is_in_recovery();
```



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



## 统计表大小

```sql
pg_table_size: The size of a table, excluding indexes.
pg_total_relation_size: Total size of a table.
pg_relation_size: The size of an object (table index, etc.) on disk. It is possible to get more detailed information from this function with additional parameters.
pg_size_pretty: Other functions return results in bytes. Converts this into readable format (kb, mb, gb)

SELECT pg_table_size('size_test_table') AS data_size,
pg_relation_size('size_test_table_pkey') AS index_size,
pg_table_size('size_test_table') + pg_relation_size('size_test_table_pkey') AS total_size1,
pg_total_relation_size('size_test_table') AS total_size2;

SELECT pg_size_pretty(pg_total_relation_size('size_test_table'));
-- 获取当前库所有表的大小
WITH tbl_spc AS (
SELECT ts.spcname AS spcname
FROM pg_tablespace ts 
JOIN pg_database db ON db.dattablespace = ts.oid
WHERE db.datname = current_database()
)
(
SELECT
t.schemaname,
t.tablename,
pg_table_size('"' || t.schemaname || '"."' || t.tablename || '"') AS table_disc_size,
NULL as index,
0 as index_disc_size,
COALESCE(t.tablespace, ts.spcname) AS tablespace
FROM pg_tables t, tbl_spc ts
UNION ALL
SELECT
i.schemaname,
i.tablename,
0,
i.indexname,
pg_relation_size('"' || i.schemaname || '"."' || i.indexname || '"'),
COALESCE(i.tablespace, ts.spcname)
FROM pg_indexes i, tbl_spc ts
)
ORDER BY table_disc_size DESC,index_disc_size DESC;
-- 获取前10大表
SELECT
t.tablename,
pg_size_pretty(pg_total_relation_size('"' || t.schemaname || '"."' || t.tablename || '"')) AS table_total_disc_size
FROM pg_tables t
WHERE
t.schemaname = 'public'  -- current_schema
ORDER BY
pg_total_relation_size('"' || t.schemaname || '"."' || t.tablename || '"') DESC
LIMIT 10;


--统计一类表的总大小
select relowner from pg_class where relname = 'tb_business_assembly_status_005';
select pg_size_pretty(sum(relpages::bigint*8*1024)) as size from pg_catalog.pg_class where relkind = 'r' and relowner = ''
and relname like "tb_business_assembly_status%" and relpages != 0;

--取表大小前500的表
select relname,pg_catalog.pg_relation_size(relid)/1024/1024 as size(MB) from pg_stat_user_tables order by size(MB) limit 1,500;
--取表大小前501-1000的表
select relname,pg_catalog.pg_relation_size(relid)/1024/1024 as size(MB) from pg_stat_user_tables order by size(MB) limit 501,500;

-- 分表统计样例
/* 
create table t1(id int ,name varchar, num int) ;
delete from t1; 
insert into t1 values (1,'a_a_a_1_00',1) ;
insert into t1 values (2,'a_a_a_1_02',2) ;
insert into t1 values (3,'b_b_01',3) ;
insert into t1 values (4,'b_b_02',4) ;
insert into t1 values (5,'c_c_01',5) ;
insert into t1 values (6,'d_01',6) ;
insert into t1 values (6,'d_02',6) ;
*/
select * from t1; 
select name,reverse(substring(reverse(name),position('_' in reverse(name))+1)) from t1; 
-- 去除最后的"下划线和数字部分"
select reverse(substring(reverse(name),position('_' in reverse(name))+1)),sum(num) as aall from t1 group by 
reverse(substring(reverse(name),position('_' in reverse(name))+1)) order by aall desc ;
-- 去除所有的"下划线和数字部分"
select regexp_replace(name, '_\d{1,10}', '', 'g') namec,sum(num) aall from t1
group by regexp_replace(name, '_\d{1,10}', '', 'g') order by aall desc ; 


-- 最终SQL
-- 获取库大小
select sum(pg_catlog.pg_relation_size(relid)/1024/1024/1024) sizegb from pg_stat_user_tables ; -- 表大小不含索引
select sum(pg_catlog.pg_total_relation_size(relid)/1024/1024/1024) sizegb from pg_stat_user_tables ; -- 表大小含索引

-- top前20的表明细
select regexp_replace(relname,'_\d{1,10}','','g') as "表名",round(sum(sizegb),2) as "总大小GB" from (select relname,pg_catlog.pg_relation_size(relid)/1024/1024/1024 as sizegb from pg_stat_user_tables ) group by regexp_replace(relname,'_\d{1,10}','','g') order by 2 desc limit 20 ;  -- 表大小(不包含索引)


select regexp_replace(relname,'_\d{1,10}','','g') as "表名",round(sum(sizegb),2) as "总大小GB" from (select relname,pg_catlog.pg_total_relation_size(relid)/1024/1024/1024 as sizegb from pg_stat_user_tables ) group by regexp_replace(relname,'_\d{1,10}','','g') order by 2 desc limit 20 ;  -- 表大小(包含索引)

-- 数据库中单个表的大小（不包含索引）
select pg_size_pretty(pg_relation_size('表名'));

-- 查出所有表（包含索引）并排序
SELECT table_schema || '.' || table_name AS table_full_name, pg_size_pretty(pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')) AS size
FROM information_schema.tables
ORDER BY
pg_total_relation_size('"' || table_schema || '"."' || table_name || '"') DESC limit 20

-- 查出表大小按大小排序并分离data与index
SELECT
table_name,
pg_size_pretty(table_size) AS table_size,
pg_size_pretty(indexes_size) AS indexes_size,
pg_size_pretty(total_size) AS total_size
FROM (
SELECT
table_name,
pg_table_size(table_name) AS table_size,
pg_indexes_size(table_name) AS indexes_size,
pg_total_relation_size(table_name) AS total_size
FROM (
SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
FROM information_schema.tables
) AS all_tables
ORDER BY total_size DESC
) AS pretty_sizes
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

### `pg_stat_replication`

>pid: WAL发送进程的进程号。
>
>username: WAL发送进程的数据库用户名。
>
>application_name： 连接WAL发送进程的应用别名，此参数显示值为备库recovery。
>
>client_addr: 连接到WAL发送进程的客户端IP地址，也就是备库的IP。
>
>backend_start: 显示WAL发送进程的状态，startup表示WAL进程在启动过程中；catchup表示备库正在追赶主库；streaming表示备库已经追赶上了主库，并且主库向备库发送WAL日志流，这个状态是流复制的常规状态；backup表示通过pg_basebackup正在进行备份；stopping表示WAL发送进程正在关闭。
>
>sent_lsn: WAL发送进程最近发送的WAL日志位置。
>
>write_lsn: 备库最近写入的WAL日志位置，这时WAL日志还在操作系统缓存中，还没写入备库WAL日志文件。
>
>flush_lsn: 备库最近写入的WAL日志位置，这时WAL日志流已写入备库WAL日志文件。
>
>replay_lsn: 备库最近应用的WAL日志位置。
>
>write_lag: 主库上WAL日志落盘后等待备库接收WAL日志（这时WAL日志流还没有写入备库WAL日志文件，还在操作系统缓存中）并返回确认信息的时间。
>
>flush_lag: 主库上WAL日志落盘后等待备库接收WAL日志（这时WAL日志流已写入备库WAL日志文件，但还没有应用WAL日志）并返回确认信息的时间。
>
>replay_lag: 主库上WAL日志落盘后等待备库接收WAL日志（这时WAL日志流已经写入备库WAL日志文件，并且已经写入WAL日志）并返回确认信息的时间。
>
>sync_priority: 基于优先级的模式中备库被选中成为同步库的优先级，对于基于quorum的选举模式此字段无影响。
>
>sync_stat: 同步状态，有以下状态值，async表示备库为异步同步模式；potential表示备库当前为异步同步模式，如果当前的同步备宕机，异步备可升级为同步备库；sync表示当前备库为同步模式；quorum表示备库为quorum standbys的候选。
>
>

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

