sqlplus sys/oracle@"(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.205)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = pdb1)))" as sysdba
sqlplus sys/oracle@tnsnames as sysdba
sqlplus sys/oracle@192.168.1.100:1521/sid as sysdba
sqlplus /nolog
conn hr/hr
sqlplus hr/hr

-- alert日志
SELECT 'tail -100f '||VALUE||case when (select platform_id from v$database) in (7,12) then '\' else '/' end ||'alert_'||(SELECT INSTANCE_NAME FROM V$INSTANCE)||'.log' "alert log"
FROM V$DIAG_INFO WHERE NAME IN ('Diag Trace');

'

-- 系统表/系统视图查询
select TABLE_NAME from all_tables where regexp_like(TABLE_NAME,'tablespace','i')
union all
select VIEW_NAME from all_views where regexp_like(VIEW_NAME,'tablespace','i');

-- 数据库状态
select DBID,NAME,DB_UNIQUE_NAME,OPEN_MODE,CREATED,LOG_MODE,PLATFORM_NAME from v$database;
-- 实例状态
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,STARTUP_TIME,STATUS,DATABASE_TYPE from v$instance;

-- redo磁盘组信息
set line 100
col GROUP# for 99
col MEMBER for a35
col SIZE for a4
col STATUS for a10

select GROUP#,t1.MEMBERS,t1.SEQUENCE#,t2.MEMBER,t1.BYTES/1024/1024 as "SIZE/MB",t1.ARCHIVED,t1.STATUS,t2.TYPE
from v$log t1 join v$logfile t2 using(GROUP#);


-- 数据文件
select * from v$dbfile;
select name from v$datafile;
select FILE_NAME from dba_data_files;

-- 临时文件
select NAME from v$tempfile;
select FILE_NAME from dba_temp_files;

-- 控制文件
select name from v$controlfile;



---------------------------------  无效对象查询，编译无效对象 ------------------------
-- 查看当前无效对象
select * from  dba_objects t where t.status = 'INVALID' order by 1;
-- 编译无效对象：
-- 方式1
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;' from dba_objects t where t.status = 'INVALID' order by 1;
-- 方式2
sqlplus / as sysdba @?/rdbms/admin/utlrp.sql



-- 查看三个自动维护任务
select * from dba_autotask_operation;

-- 关闭3个自动维护任务
-- 参考：  https://cloud.tencent.com/developer/article/1605034
BEGIN
 dbms_auto_task_admin.disable(
   client_name => 'auto optimizer stats collection',
   operation   => NULL,
   window_name => NULL);
 dbms_auto_task_admin.disable(
   client_name => 'auto space advisor',
   operation   => NULL,
   window_name => NULL);
 dbms_auto_task_admin.disable(
   client_name => 'sql tuning advisor',
   operation   => NULL,
   window_name => NULL);
END;


