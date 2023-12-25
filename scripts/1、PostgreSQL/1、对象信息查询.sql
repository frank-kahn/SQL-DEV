-- 查询表的注释
select t2.nspname,t1.relname,t3.description as commnet
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
left join pg_description t3 on t1.oid=t3.objoid
where t1.relname='test_t';

-- 查看表跟索引大小
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
		   select (''''||table_schema||'''.'''||table_name||'''') as table_name
		     from information_schema.tables
		 )	as all_tables	
		 order by total_size desc
   ) as pretty_sizes;