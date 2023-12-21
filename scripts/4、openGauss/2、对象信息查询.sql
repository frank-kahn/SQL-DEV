-- 查询表示有哪些全局索引
select t3.relname as tablename,t1.relname as index_name from pg_class t1
  join pg_index t2 on (t1.oid=t2.indexrelid)
  join pg_class t3 on (t3.oid=t2.indrelid)
  where t3.relname='test_range_t'
  and t1.relkind='I';

-- 查看表上有哪些索引（除去全局索引，其他的都是本地索引）
select schemaname,tablename,indexname from pg_indexes where tablename = 'test_range_t';

-- 查看某个库下模糊匹配表或视图名
select table_catalog,table_schema,table_name,table_type from information_schema.tables
where table_type in ('BASE TABLE','VIEW') and table_name ~ 'name' and table_catalog= '';