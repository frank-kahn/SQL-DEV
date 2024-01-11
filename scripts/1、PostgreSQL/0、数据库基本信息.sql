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
