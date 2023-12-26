-- 数据库大小查询
SELECT d.datname as "Name",
       pg_catalog.pg_get_userbyid(d.datdba) as "Owner",
       pg_catalog.pg_encoding_to_char(d.encoding) as "Encoding",
       d.datcollate as "Collate",
       d.datctype as "Ctype",
       d.datacl AS "Access privileges",
       --pg_catalog.array_to_string(d.datacl, E'\n') AS "Access privileges",
       CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
            THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname))
            ELSE 'No Access'
       END as "Size",
       t.spcname as "Tablespace",
       pg_catalog.shobj_description(d.oid, 'pg_database') as "Description"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
-- where d.datname = 'database_name'
ORDER BY 1;


-- 查询数据库下模式的大小
SELECT 
  schema_name, 
  round((sum(table_size)::bigint)/1024/1024,2) as "disk space/MB", 
  round((sum(table_size)/pg_database_size(current_database()))* 100,2)  as "percent" 
FROM 
  (
    SELECT 
      pg_catalog.pg_namespace.nspname as schema_name, 
      pg_relation_size(pg_catalog.pg_class.oid) as table_size 
    FROM 
      pg_catalog.pg_class 
      JOIN pg_catalog.pg_namespace 
      ON relnamespace = pg_catalog.pg_namespace.oid
  ) t 
-- where t.schema_name = 'schema_name'
GROUP BY schema_name 
ORDER BY schema_name;


-- 查看模式下大对象，按照大小降序排序
SELECT n.nspname as "Schema",
  c.relname,
  c2.relname as "Table_name",
  CASE c.relkind WHEN 'r' THEN 'table'
                WHEN 'v' THEN 'view'
          WHEN 'm' THEN 'materialized view'
          WHEN 'i' THEN 'index'
          WHEN 'S' THEN 'sequence'
          WHEN 's' THEN 'special'
          WHEN 'f' THEN 'foreign table'
          WHEN 'p' THEN 'partitioned table'
          WHEN 'I' THEN 'partitioned index' END as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size",
  pg_catalog.obj_description(c.oid, 'pg_class') as "Description"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
     LEFT JOIN pg_catalog.pg_class c2 ON i.indrelid = c2.oid
WHERE 1=1
      --and c.relkind IN ('r','p','v','m','S','f','')
      --AND n.nspname <> 'pg_catalog'
      --AND n.nspname <> 'information_schema'
      --AND n.nspname !~ '^pg_toast'
      --AND pg_catalog.pg_table_is_visible(c.oid)
      and n.nspname = 'schema_name'
ORDER BY pg_catalog.pg_table_size(c.oid) desc;


-- 当前库下表总大小、表数据大小、索引大小
select schemaname as table_schema,
relname as table_name,
pg_size_pretty(pg_total_relation_size(relid)) as total_size,
pg_size_pretty(pg_relation_size(relid)) as data_size,
pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as external_size
from pg_catalog.pg_statio_user_tables
order by pg_total_relation_size(relid) desc,pg_relation_size(relid) desc 
limit 10;


-- 查看表跟索引大小（数据库级别）
select table_name,
        pg_size_pretty(table_size) as table_size,
		pg_size_pretty(indexes_size) as indexes_size,
		pg_size_pretty(total_size) as total_size
   FROM
   (
     select table_name,
             pg_table_size(table_name) as table_size,
		     pg_indexes_size(table_name) as indexes_size,
		     pg_total_relation_size(table_name) as total_size
        FROM
         (
		   select ('"'||table_schema||'"."'||table_name||'"')  as table_name
		     from information_schema.tables
		 )	as all_tables	
		 order by total_size desc
   ) as pretty_sizes;
   

-- 表空间大小
select pg_size_pretty (pg_tablespace_size ('pg_default'));
-- 数据库大小
select pg_size_pretty (pg_database_size ('testdb'));
-- 表总大小
select pg_size_pretty (pg_total_relation_size ('test_t'));
-- 表数据大小
select pg_size_pretty (pg_relation_size('test_t'));
-- 表索引总大小
select pg_size_pretty (pg_total_relation_size ('test_t')-pg_relation_size('test_t'));
-- 单个索引的大小
select pg_size_pretty (pg_indexes_size('索引名字'));
-- 列大小
select pg_size_pretty (sum(pg_column_size(column_name::text))) from table_name;
-- 查询临时文件大小
select pg_size_pretty(sum(size)) from pg_ls_tmpdir();
-- wal目录大小
select pg_size_pretty(sum(size)) from pg_ls_waldir();
-- 归档目录大小（有问题待研究）
"E:\document\学习笔记\code\learning\Knowledge Base\PostgreSQL\sql命令查看归档目录大小.md"



   
