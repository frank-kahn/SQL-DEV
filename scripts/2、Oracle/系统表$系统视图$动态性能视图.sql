gv$lock
gv$process
gv$session
v$latchname
v$lock
v$locked_object
v$process
v$rollname
v$rollstat
v$session
v$session_longops
v$transaction
v$instance_recovery
-- 依赖关系
dba_dependencies
-- 查询坏块信息
v$database_block_corruption

--查看恢复区是使用情况 
select * from v$flash_recovery_area_usage;
select * from v$parameter where name like '%recover%';



-- 查询恢复视图
col ERROR format a30
set linesize 200
set pagesize 200

SQL> select * from v$recover_file;