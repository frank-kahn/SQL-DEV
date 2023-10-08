-- 数据库状态
select DBID,NAME,DB_UNIQUE_NAME,OPEN_MODE,CREATED,LOG_MODE,PLATFORM_NAME from v$database;
-- 实例状态
select INSTANCE_NUMBER,INSTANCE_NAME,HOST_NAME,STARTUP_TIME,STATUS,DATABASE_TYPE from v$instance;

-- redo磁盘组信息
set line 100
col GROUP# for 9
col MEMBER for a35
col SIZE for a4
col STATUS for a10

select GROUP#,t1.MEMBERS,t1.SEQUENCE#,t2.MEMBER,t1.BYTES/1024/1024 as "SIZE/MB",t1.ARCHIVED,t1.STATUS,t2.TYPE
from v$log t1 join v$logfile t2 using(GROUP#);
