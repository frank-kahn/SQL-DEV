-- 查看是否开启ssl
select name,setting,unit,context from pg_settings where name ~* 'ssl';

可以通过查询pg_stat_ssl视图来查看客户端连接是否使用ssl，如果客户端使用ssl连接，则该视图中会显示相应的连接信息
select * from pg_stat_ssl;