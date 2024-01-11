-- 查询表的注释
select t2.nspname,t1.relname,t3.description as commnet
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
left join pg_description t3 on t1.oid=t3.objoid
where t1.relname='test_t';


-- 当前库下所有schema下没有主键的表
SELECT n.nspname as schema_name,
       c.relname as table_name
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_constraint con ON con.conrelid = c.oid AND con.contype = 'p'
WHERE c.relkind = 'r' -- only regular tables
  AND n.nspname NOT IN ('pg_catalog', 'information_schema') -- exclude system schemas
  AND con.oid IS NULL -- no primary key
ORDER BY schema_name, table_name;
