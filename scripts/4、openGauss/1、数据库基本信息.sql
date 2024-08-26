-- 查看某个库下模糊匹配表或视图名
select table_catalog,table_schema,table_name,table_type from information_schema.tables
where table_type in ('BASE TABLE','VIEW') and table_name ~ 'name' and table_catalog= '';

--根据字段名查询系统表/系统视图
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


-- 查询函数信息
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'path';

