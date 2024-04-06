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


-- PostgreSQL查看序列是否依赖于某个表（绑定到了表的字段）
create table test_t(id int,name text);
create sequence test_s;
alter sequence test_s owned by test_t.id;

select t2.relname as 表名,
        t3.relname as 序列名,
		t4.attname as 序列绑定的表的列
		-- ,objid as 序列oid,refobjid as 表oid,refobjsubid as 列序号
  from pg_depend t1
  join pg_class t2 on t2.oid=t1.refobjid
  join pg_class t3 on t3.oid=t1.objid
  join pg_attribute t4 on t4.attrelid=t2.oid
where 1=1
   and t4.attnum=t1.refobjsubid
   and t3.relkind='S';

-- 查询表字段上绑定的序列名称
select pg_get_serial_sequence('表名','字段名');


