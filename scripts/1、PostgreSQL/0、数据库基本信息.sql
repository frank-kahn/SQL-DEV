-- 数据库基本信息
select 
     to_char(now(),'yyyy-mm-dd hh24:mi:ss') "巡检时间"
    ,to_char(pg_postmaster_start_time(),'yyyy-mm-dd hh24:mi:ss') "pg_start_time(启动时间)"
    ,now()-pg_postmaster_start_time() "pg_running_time(运行时长)"
    --,inet_server_addr() "server_ip(服务器ip)"
    --,inet_server_port() "server_port(服务器端口)"
    --,inet_client_addr() "client_ip(客户端ip)"
    --,inet_client_port() "client_port(客户端端口)"
    ,version() "server_version(数据库版本)"
    ,(case when pg_is_in_recovery()='f' then 'primary' else 'standby' end ) as  "primary_or_standby(主或备)";


-- 查看某个库下模糊匹配表或视图名
select table_catalog,table_schema,table_name,table_type from information_schema.tables
where table_type in ('BASE TABLE','VIEW') and table_name ~ 'name' and table_catalog= '';

-- 查询函数信息
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'fresh';

-- 获取当前事务日志的写入位置（LSN）
select pg_current_wal_lsn();
-- 获取当前事务日志的写入位置，并转换成对应的文件命名格式
select * from pg_walfile_name('0/163B538');
select * from pg_walfile_name(pg_current_wal_lsn());

-- 查看表物理存放位置
select pg_relation_filepath('employees');


--插件存放路径
--1、sql文件和control文件
$PGHOME/share/postgresql/extension
--2、so文件
$PGHOME/lib/postgresql
