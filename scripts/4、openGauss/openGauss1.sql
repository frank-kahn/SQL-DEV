--排查是否存在xid不推进问题
select datname,datfrozenxid64 from pg_database;
select relname,relfrozenxid64 from pg_class
where relfrozenxid64::text<>'0' and relname <> 'pg_%'
order by (relfrozenxid64::text)::int8;



--查看top10大表
select relname,
		pg_relation_size('public."'||relname||'"') as MB,
		relkind
from pg_class
where relnamespace in
	(select oid
	from pg_namespace
	where nspname not in(
						'pg_toast',
						'pg_temp_1',
						'pg_toast_temp_1',
						'pg_catalog',
						'information_schema'
							))
and relkind='r';




--分表总和大小
select 
  tablename, 
  sizeallgb "总大小包含索引GB", 
  sizeallgb2 "表大小GB", 
  sizeallgb - sizeallgb2 "索引大小GB" 
from 
  (
    select 
      regexp_replace(relname, '_\d{1,10}', '', 'g') tablename, 
      round(sum(sizegb),2) sizeallgb, 
      round(sum(sizegb2),2) sizeallgb2 
    from 
      (
        select 
          relname, 
          pg_catalog.pg_total_relation_size(relid)/ 1024  / 1024 sizegb, 
          pg_catalog.pg_relation_size(relid)/ 1024/ 1024 sizegb2 
        from 
          pg_stat_user_tables 
        where 
          regexp_replace(relname, '_\d{1,10}', '', 'g') in ('employees', 'student')
      ) 
    group by 
      regexp_replace(relname, '_\d{1,10}', '', 'g')
  ) 
order by 2 desc;




-- 查看指定模式下表的元组数、页数、大小等信息
select 
  t2.schemaname, 
  t1.relname, 
  round(pg_total_relation_size(t1.relname::regclass)/ 1024 / 1024, 2) as "total_size/mb", 
  round((pg_total_relation_size(t1.relname::regclass)- pg_relation_size(t1.relname ::regclass))/ 1024/ 1024, 2) as "index_size/mb", 
  t1.relpages, 
  t1.reltuples, 
  t2.n_live_tup, 
  t2.n_dead_tup, 
  t2.last_vacuum, 
  t2.last_autovacuum, 
  t2.last_data_changed 
from 
  pg_class t1 
  join pg_stat_sys_tables t2 on(t1.oid = t2.relid) 
where 
  t2.schemaname = 'pg_catalog' 
  and t1.relkind = 'r';