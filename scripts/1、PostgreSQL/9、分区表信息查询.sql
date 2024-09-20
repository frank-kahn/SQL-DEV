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
-- 查询普通表和分区表的主表（不查询分区表子表）
select t2.nspname as schema,
       t1.relname as tablename,
	   case when t1.relkind='r' then '普通表'
	        when t1.relkind='p' then '分区表主表' end as table_type
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
 where t1.relkind in ('r','p')
 and t1.relispartition='f'
 and t2.nspname = '模式名';




-- 查看分区表的分区数量
select count(*) from pg_inherits
where inhparent='tbp'::regclass;

-- 查看分区表的子表
select inhrelid::regclass from pg_inherits
where inhparent = 'tbp'::regclass;


-- 获取分区类型和KEY（查询的是主表）         
SELECT pg_get_partkeydef('tbp'::regclass); 

-- 获取分区范围（查询的是子表）
SELECT pg_get_partition_constraintdef('tbp_1'::regclass) ;


-- 查询分区表的记录数（查询的是主表，预估行数）
SELECT
    nspname AS schema_name,
    relname AS partition_name,
    pg_size_pretty(pg_relation_size(C.oid)) AS partition_size,
    pg_size_pretty(pg_total_relation_size(C.oid)) AS total_partition_size,
    (SELECT reltuples FROM pg_class WHERE oid = C.oid) AS row_estimate
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE relkind in ('p','r')
AND nspname NOT IN ('pg_catalog', 'information_schema')
AND relname in (
select relid::text from pg_partition_tree('tbp')
)
ORDER BY relname;

-- 查询分区表的记录数（查询的是主表，精确数据）
select tableoid::regclass,count(*) from tbp
group by 1 order by 1;

-- 相关函数
pg_partition_tree()   显示分区表信息
https://blog.csdn.net/forrest_hu/article/details/133751842