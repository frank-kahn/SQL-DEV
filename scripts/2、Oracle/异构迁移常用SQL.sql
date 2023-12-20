1.筛选大表
1.1.查看业务用户下每个表的行数
select owner, table_name, num_rows
  from dba_tables
 where owner = 'SYS'
   and num_rows > 5000
 order by 3 desc;
 
1.2.查看业务用户下每个表或者索引的占用空间
select owner, segment_name, sum(bytes) / 1024 / 1024 "占用空间（mb）"
  from dba_segments
 where owner in ('SYS')
   and segment_type = 'TABLE'
 group by owner, segment_name
 order by 3 ;

select owner, segment_name, sum(bytes) / 1024 / 1024 "占用空间（mb）"
  from dba_segments
 where owner in ('SYS')
   and segment_type = 'INDEX'
 group by owner, segment_name
 order by 3 desc;
 
1.3.查看业务用户下每个表行数,表段和索引段占用空间之和
with t_tab as
     (select a.owner,
              a.table_name,
              a.num_rows,
              sum(b.bytes)/1024/1024 mb
         from dba_tables a,
              dba_segments b
        where a.table_name=b.segment_name
          and a.owner=b.owner
          and a.owner in ('SYS')
          and a.num_rows>1000
     group by a.owner,
              a.table_name,
              a.num_rows
     )
     ,
     t_ind as
     (select a.owner,
              a.table_name,
              a.index_name,
              sum(b.bytes)/1024/1024 mb
         from dba_indexes a,
              dba_segments b
        where a.index_name=b.segment_name 
          and a.owner=b.owner
     group by a.owner,
              a.table_name,
              a.index_name
     )
   select t_tab.owner,
          t_tab.table_name ,
          t_tab.num_rows, 
          t_tab.mb as table_size_mb, 
          nvl(t_ind.mb,0) as index_size_mb,
          (t_tab.mb+nvl(t_ind.mb,0)) as total_size_mb
     from t_tab
left join t_ind
       on t_tab.owner=t_ind.owner
      and t_tab.table_name=t_ind.table_name
 order by 4 desc;
 
2.分区表
2.1.查看是一级分区还是二级分区表
SELECT distinct owner, table_name, partitioning_type
FROM dba_tab_partitions
WHERE owner = 'SYS';

3.大字段表
SELECT t.owner AS 用户名,
       t.table_name AS 表名,
       t.num_rows AS 表行数,
       round((s.bytes / 1024 / 1024), 2) AS 表大小_MB
  FROM dba_segments s
  JOIN dba_lobs l
    ON s.segment_name = l.segment_name
   AND s.owner = l.owner
  JOIN dba_tables t
    ON l.table_name = t.table_name
   AND l.owner = t.owner
  JOIN dba_tab_columns c
    ON c.table_name = t.table_name
   AND c.owner = t.owner
 WHERE t.owner NOT IN ('SYS', 'SYSTEM')
   AND t.tablespace_name NOT IN ('SYSAUX', 'SYSTEM')
   AND t.degree != 'DEFAULT'
   AND c.data_type IN
       ('CLOB', 'NCLOB', 'BLOB', 'LONG', 'LONG RAW', 'BFILE')
 ORDER BY s.bytes DESC;

4.没有主键或者唯一建的表
4.1.Oracle查询SQL
SELECT t.owner, t.table_name
  FROM dba_tables t
  LEFT JOIN dba_constraints c
    ON t.owner = c.owner
   AND t.table_name = c.table_name
   AND c.constraint_type IN ('P', 'U')
 WHERE t.owner = 'SYSDBA'
   AND c.table_name IS NULL
   AND t.table_name IS NOT NULL;
		   
4.2.DM查询SQL(指定模式)
    select t.name
      from syscons c
right join sysobjects t
        on (c.tableid = t.id 
                  and c.type$ = 'P')
     where t.subtype$='UTAB'
       and t.schid = sf_get_schema_id_by_name('SYSDBA')
       and c.id is null
 
5.备份表或者带log日志表
with t_tab as
     (select a.owner,
              a.table_name,
              a.num_rows,
              sum(b.bytes)/1024/1024 mb
         from dba_tables a,
              dba_segments b
        where a.table_name=b.segment_name
          and a.owner=b.owner
          and a.owner in ('SYS')
		  and (a.table_name like '%BAK%' OR a.table_name LIKE '%bak%' OR a.table_name like '%LOG%' OR a.table_name LIKE '%log%')
          and a.num_rows>1000
     group by a.owner,
              a.table_name,
              a.num_rows
     )
     ,
     t_ind as
     (select a.owner,
              a.table_name,
              a.index_name,
              sum(b.bytes)/1024/1024 mb
         from dba_indexes a,
              dba_segments b
        where a.index_name=b.segment_name 
          and a.owner=b.owner
     group by a.owner,
              a.table_name,
              a.index_name
     )
   select t_tab.owner,
          t_tab.table_name ,
          t_tab.num_rows, 
          t_tab.mb as table_size_mb, 
          nvl(t_ind.mb,0) as index_size_mb,
          (t_tab.mb+nvl(t_ind.mb,0)) as total_size_mb
     from t_tab
left join t_ind
       on t_tab.owner=t_ind.owner
      and t_tab.table_name=t_ind.table_name
 order by 4 desc;

6.临时表
SELECT owner, table_name, temporary_tablespace 
FROM dba_tables
WHERE temporary = 'Y';


7.物化视图日志表
SELECT owner, mview_name, log_table
FROM dba_mviews
WHERE owner = 'Your_User'
AND log_owner = 'Your_User';

8.内部表
根据实际情况添加disable参数

8.查看用户对象数据总数
8.1达梦指定模式查询
  select count(*), 
         subtype$ 
    from sysobjects 
   where schid = sf_get_schema_id_by_name('PAPERLESS_CONFERENCE') 
group by subtype$;

8.2 通用查询
  select object_type, 
         count(object_name) 
    from dba_objects 
   where owner = 'PAPERLESS' 
     and object_type not like 'SCH' 
group by object_type;

9.查询归档量
select to_char(completion_time, 'yyyy-mm-dd') as date1,
       count(0) as cnt,
       round(sum((blocks * block_size) / 1024 / 1024)) as mb
  from v$archived_log
 group by to_char(completion_time, 'yyyy-mm-dd')
 order by date1 desc;