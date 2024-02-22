-- 查询表的索引信息（支持分区表的子表）
select d.nspname as schemaname,
       b.relname as tablename,
	   c.relname as indexname,
	   pg_relation_size(c.oid)/1024/1024 as size_mb,
	   a.indnatts,
	   a.indisunique,
	   a.indisprimary,
	   a.indisvalid,
	   a.indisready,
	   a.indcheckxmin,
	   e.indexdef
from
	pg_index a,
    pg_class b,
    pg_class c,
    pg_namespace d,
    pg_indexes e
where 
   a.indrelid =b.oid
   and a.indexrelid=c.oid
   and b.relnamespace=d.oid
   and d.nspname=e.schemaname
   and b.relname=e.tablename
   and c.relname=e.indexname
   and b.relname='test';


--------------------------- 查看表是普通表还是分区表 -------------------------
-- relispartition 主表为f 子表为t    relhassubclass 主表为t 子表为f
-- 方式1
select t2.nspname as schema,
       t1.relname as tablename,
	   case when t1.relkind='r' then '普通表/分区表的子表'
	        when t1.relkind='p' then '分区表' end as table_type
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
 where t1.relkind in ('r','p')
 and t1.relname ~ 'tbp';
-- 方式2
select t3.nspname as schema,
       t1.relname,
	   case when t2.partstrat='r' then '范围分区表'
	   when t2.partstrat='l' then '列表分区表'
	   when t2.partstrat='h' then '哈希分区表' end as partition_type
from pg_class t1
join pg_partitioned_table t2 on t1.oid=t2.partrelid
join pg_namespace t3 on t1.relnamespace=t3.oid
where t1.relname ~ 'tbp';


-- 查看分区表的分区数量
select count(*) from pg_inherits
where inhparent='tbp'::regclass;

-- 查看分区表的子表
select inhrelid::regclass from pg_inherits
where inhparent = 'tbp'::regclass;