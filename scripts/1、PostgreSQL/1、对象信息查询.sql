-- 内存使用情况
select c.relname,
       pg_size_pretty(count(*)*8192) as buffered,
	   round(100.0*count(*)/(select setting from pg_settings where name='shared_buffers')::int,1) as buffers_percent,
	   round(100.0*count(*)*8192/pg_relation_size(c.oid),1) as percent_of_relation
	from pg_class c 
	 join pg_buffercache b on b.relfilenode=c.relfilenode
	 join pg_database d on b.reldatabase =d.oid and d.datname=current_database()
	group by c.oid,c.relname
	order by 3 desc
	limit 10;

	