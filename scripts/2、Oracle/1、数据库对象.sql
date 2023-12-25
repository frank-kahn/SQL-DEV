-- 用户
create user yaokang identified by yaokang;
alter user sys identified by oracle;



--查看目录
select DIRECTORY_NAME,DIRECTORY_PATH from dba_directories;
--创建目录和授权
create or replace directory dump_dir as '/home/oracle/backup';
grant read,write on directory dump_dir to system;
--删除目录
drop directory dump_dir;

-- 查询所有数据文件的路径信息
select name from v$controlfile union all
select value from v$parameter where name='spfile' union all
select MEMBER from v$logfile where rownum<=1 union all
select FILE_NAME from dba_data_files where rownum<=1 union all 
select FILE_NAME from dba_temp_files where rownum<=1 union all
select NAME from v$archived_log where rownum<=1 and length(name)>0;

-- 查询Oracle系统schema
select username from dba_users where default_tablespace in ('SYS','SYSAUX');

