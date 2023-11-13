-- 查询表的注释
select t2.nspname,t1.relname,t3.description as commnet
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
left join pg_description t3 on t1.oid=t3.objoid
where t1.relname='test_t';