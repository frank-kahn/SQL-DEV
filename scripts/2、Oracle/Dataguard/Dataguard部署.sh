# 11g

#删除备库的实例
dbca -silent -deleteDatabase -sourceDB testdbb -sysdbaUserName sys -sysDBAPassword oracle

#修改glogin.sql
cat > /oracle/app/oracle/product/11.2.0/db/sqlplus/admin/glogin.sql << "EOF"
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set termout off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
define gname=idle
column global_name new_value gname
select lower(user)||'@'||lower(instance_name)||'('||lower(host_name)||')' global_name from v$instance;
set sqlprompt '&gname> '
set termout on
EOF


#删除多余的redo日志组
alter database drop logfile group 11;
alter database drop logfile group 12;
alter database drop logfile group 13;
alter database drop logfile group 14;
alter database drop logfile group 15;
#创建redo日志组
alter database add logfile group 4 '/oracle/oradata/testdba/redo04.log' size 100m;
alter database add logfile group 5 '/oracle/oradata/testdba/redo05.log' size 100m;

#关闭omf特性（创建pfile后修改）
*.db_create_file_dest=''









#在线脱库
run {
allocate channel p1 type disk;
allocate channel p2 type disk;
allocate auxiliary channel s1 type disk;
allocate auxiliary channel s2 type disk;
duplicate target database for standby from active database nofilenamecheck;
release channel p1;
release channel p2;
release channel s1;
release channel s2;
}



#基于备份
run {
allocate auxiliary channel s1 type disk;
allocate auxiliary channel s2 type disk;
allocate auxiliary channel s3 type disk;
allocate auxiliary channel s4 type disk;
duplicate target database for standby nofilenamecheck;
release channel s1;
release channel s2;
release channel s3;
release channel s4;
}



#实时同步原理（real time apply）
主库的lgwr进程负责写日志，把主库的所有数据变化写进redo log files里面
在Dataguard日志同步模式下，还会把redo log files里面写入的信息镜像到备库，
备库有RFS进程接收，写入到Standby redo log files，所以需要创建Standby redo log files（主库创建）

#非实时同步
主库的redo log files归档之后，同步到备库，再从备库做恢复





#相关检查
-- 数据库角色和状态查询
select NAME,DATABASE_ROLE,OPEN_MODE,PROTECTION_MODE,SWITCHOVER_STATUS from v$database;
select dbid,name,current_scn,database_role,open_mode,protection_mode,force_logging,switchover_status from v$database;
-- 查询归档路径信息
col DEST_NAME for a20
col STATUS for a8
select DEST_NAME,STATUS,ERROR from v$archive_dest;
-- 查看进程信息
select PROCESS,CLIENT_PROCESS,SEQUENCE#,STATUS from v$managed_standby;
-- 查看最后的日志信息
SELECT UNIQUE THREAD#, MAX(SEQUENCE#) OVER(PARTITION BY THREAD#) LAST FROM V$ARCHIVED_LOG;
-- 是否归档间隙（仅在备库查询）
SELECT THREAD#, LOW_SEQUENCE#, HIGH_SEQUENCE# FROM V$ARCHIVE_GAP;
-- 是否存在未被应用的日志（仅在备库查询）
select thread#,sequence#,first_time,next_time,applied from v$archived_log where applied='NO';




####################  测试数据
-- 主库创建
create tablespace test05 datafile '/oracle/oradata/testdba/test05.dbf' size 50m;
create user test05 identified by test05 default tablespace test05;
grant dba to test05;
conn test05/test05;
create table test05 (id number(2) primary key,name varchar2(10));
insert into test05 values(1,'test01');
insert into test05 values(2,'test02');
insert into test05 values(3,'test03');
insert into test05 values(4,'test04');
insert into test05 values(5,'test05');
commit;
select * from test05.test05;
alter system switch logfile;   -- 主库未归档前，备库是查询不到数据的

drop tablespace ts01 including contents and datafiles CASCADE CONSTRAINTS;




-- 备库查询
select * from test05.test05;






# 归档式同步（主库的redo记录归档后，才同步）
alter database recover managed standby database disconnect from session;
# 实时同步：
alter database recover managed standby database using current logfile disconnect from session;
# 取消恢复：
alter database recover managed standby database cancel;


alter system switch logfile;




########################################## 修复gap
select current_scn from v$database;
select min(checkpoint_change#) from v$datafile_header
where file# not in (select file# from v$datafile where enabled = 'READ ONLY');

run {
allocate channel ch1 type disk maxpiecesize 30G;
backup as compressed backupset incremental from scn xxx database format '/backup/inc_%d_%T_%s_%p_%u.bak' tag 'inc_bak';
release channel ch1
}









Oracle Data Guard 折腾记（一）
https://www.cnblogs.com/killkill/archive/2010/12/18/1910267.html
https://www.cnblogs.com/killkill/archive/2010/12/20/1911172.html





