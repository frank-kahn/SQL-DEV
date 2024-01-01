v$datafile 是从oracle的控制文件中获得的数据文件的信息
v$datafile_header 是从数据文件的头部
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

-- 查看byte大小
DBMS_XPLAN.FORMAT_SIZE(BYTES)

-- 查看恢复区是使用情况 
select * from v$flash_recovery_area_usage;
select * from v$parameter where name like '%recover%';

-- 监听状态视图
select * from V$LISTENER_STATUS;

-- 密码文件视图（如果没有结果集返回，则说明密码文件有问题）
v$pwfile_users

-- 查询恢复视图
col ERROR format a30
set linesize 200
set pagesize 200

SQL> select * from v$recover_file;

