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