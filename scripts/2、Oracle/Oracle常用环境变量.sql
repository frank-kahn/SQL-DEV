for i in 192.168.1.8{1..3};do
echo $i
sqlplus -s sys/oracle@$i:1521/rac_db as sysdba << EOF
set line 100
show parameter local_listener
EOF
done

select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') as now from dual;
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS'; 


export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1 
export PATH=$PATH:/opt/oracle/product/19c/dbhome_1/bin 
export ORACLE_SID=ORCLCDB


-- sqlplus常用设置
vi $ORACLE_HOME/sqlplus/admin/glogin.sql

set serveroutput on
set pagesize 5000
column plan_plus_exp format a80
column global_name new_value gname
set termout off
define gname=SQL
column global_name new_value gname
select lower(user)||'@'||lower(instance_name)||'('||(select distinct sid from v$mystat)||')' global_name from v$instance;
set sqlprompt '&gname> '
set termout on

-- oracle环境变量
PS1="[`whoami`@`hostname`:"'$PWD]$'
export PS1
NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS";export NLS_DATE_FORMAT
alias sqlplus="rlwrap sqlplus"
alias rman="rlwrap rman"
alias alert="tail -100f /oracle/app/oracle/diag/rdbms/fghsdb/fghsdb/trace/alert_fghsdb.log"



define _editor=vi
set serveroutput on size 1000000
set trimspool on				--去除重定向（spool）输出每行的拖尾空格，缺省为off
set timing on					--显示执行sql语句耗时信息，默认是off状态
set long 5000
set pagesize 5000
set linesize 1024
column plan_plus_exp format a80
column global_name new_value gname
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
set termout off				--显示脚本中的命令的执行结果，缺省为on
define gname=none
column global_name new_value gname
select lower(user)||'@'||lower(instance_name)||'('||(select distinct sid from v$mystat)||')' global_name from v$instance;
set sqlprompt '&gname> '
set termout on

define gname=idle
column global_name new_value gname
select lower(user) || '@' || substr( global_name, 1, decode( dot, 0, length(global_name), dot-1) ) global_name from (select global_name, instr(global_name,'.') dot from global_name );
set sqlprompt '&gname _DATE> '






set serveroutput on size 1000000
set pagesize 1000       -- set PAGESIZE 0 代表什么意思
set linesize 100
set long 200000			-- long代表什么意思
set trimspool on        -- 这个是什么意思 
set termout off         -- 这个是什么意思
col parameter for a30
col value for a40
set head off
set verify off
set feedback off
set numwidth 7

