-- 执行计划查看
explain(analyze true,verbose true,costs true,buffers true,timing true,format text)


--查询最近的业务表的autovacuum情况
select schemaname,relname,last_vacuum,last_autovacuum from pg_stat_user_tables
where schemaname='pg_catalog'
order by last_autovacuum desc nulls last;