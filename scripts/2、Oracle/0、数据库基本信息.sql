sqlplus sys/oracle@"(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.205)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = pdb1)))" as sysdba
sqlplus sys/oracle@tnsnames as sysdba
sqlplus sys/oracle@192.168.1.100:1521/sid as sysdba
sqlplus /nolog
conn hr/hr
sqlplus hr/hr

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
