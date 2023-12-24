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