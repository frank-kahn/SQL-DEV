for i in 192.168.1.8{1..3};do
echo $i
sqlplus -s sys/oracle@$i:1521/rac_db as sysdba << EOF
set line 100
show parameter local_listener
EOF
done

select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') as now from dual;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';

-- oracle环境变量
PS1="[`whoami`@`hostname`:"'$PWD]$'
export PS1
NLS_DATE_FORMAT="yyyy-mm-dd HH24:MI:SS";export NLS_DATE_FORMAT
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1 
export PATH=$PATH:/opt/oracle/product/19c/dbhome_1/bin 
export ORACLE_SID=ORCLCDB
alias sqlplus="rlwrap sqlplus"
alias rman="rlwrap rman"
alias alert="tail -100f /oracle/app/oracle/diag/rdbms/fghsdb/fghsdb/trace/alert_fghsdb.log"


-- Windows（加上/M是系统变量，不加的话是用户变量）
setx /M NLS_LANG "SIMPLIFIED CHINESE_CHINA.UTF8"
setx /M NLS_DATE_LANGUAGE "SIMPLIFIED CHINESE"
setx /M NLS_DATE "YYYY-MM-DD HH24:MI:SS.FF6"
setx /M NLS_TIMESTAMP_FORMAT "YYYY-MM-DD HH24:MI:SS.FF6"

#命令行执行，或者编写为vbs脚本
SETX "PGHOME"  "D:\db\PostgreSQL\13.2-2"
SETX "PGHOST"  "localhost"
SETX "PGLIB"   "%PGHOME%\lib"
SETX "PGDATA"  "%PGHOME%\data"

#设置环境path环境变量
%PGHOME%\bin





-- sqlplus常用设置
vi $ORACLE_HOME/sqlplus/admin/glogin.sql

-- SQLPLUS默认编辑器设置为vi
define _editor=vi
-- 默认打开DBMA_OUTPUT,这样不必要每次在输入这个命令，同时将默认缓冲池设置得尽可能大
set serveroutput on size 1000000
-- 设置选择LONG和CLOB列时显示的默认字节数
set long 5000
-- 设置SQLPLUS多久打印一次标题，将此参数设置大些这样每页只显示一次标题
set pagesize 1000
-- 设置显示的文本宽为100个字符
set linesize 100
-- 去除重定向（spool）输出每行的拖尾空格，缺省为off
set trimspool on
-- 显示执行sql语句耗时信息，默认是off状态
set timing on
-- 实时显示当前时间
set time on
-- 设置AUTOTRACE得到解释计划输出的默认宽度，一般80足够放下整个计划
column plan_plus_exp format a80
-- 不显示脚本中的命令的执行结果，缺省为on
set termout off
-- 不显示列标题
set head off
-- 当在sqlplus中运行的sql语句中有替代变量（以&或&&打头）的时候，set verify(或ver) on/off可以设置是否显示替代变量被替代前后的语句。
set verify off
-- 是否显示当前sql语句查询或修改的行数
set feedback off
-- 数字长度
set numwidth 7





-- hh24:mi:ss  SQL(会话ID)>

~~~shell
#同时会显示sql执行耗时
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set timing on
set time on
set termout off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
define gname=SQL
column global_name new_value gname
select 'SQL('||(select distinct sid from v$mystat)||')' global_name from v$instance;
set sqlprompt '&gname> '
set termout on
~~~

-- user@instance_name yyyy-mm-dd hh24:mi:ss>

~~~shell
#instance_name是大写的
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set termout off
define gname=idle
column global_name new_value gname
select lower(user) || '@' || substr( global_name, 1, decode( dot, 0, length(global_name), dot-1) ) global_name from (select global_name, instr(global_name,'.') dot from global_name );
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
set sqlprompt '&gname _DATE> '
set termout on





#instance_name是小写的
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set termout off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
define gname=idle
column global_name new_value gname
select lower(user)||'@'||lower(instance_name) global_name from v$instance;
ALTER SESSION SET nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
set sqlprompt '&gname _DATE> '
set termout on


#用户是大写，instance_name是实际大小写
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set termout off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER _DATE> "
set termout on
~~~



-- user@instance_name(会话ID)

~~~shell
set serveroutput on size 1000000
set long 5000
set pagesize 1000
set linesize 100
set termout off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';
define gname=idle
column global_name new_value gname
select lower(user)||'@'||lower(instance_name)||'('||(select distinct sid from v$mystat)||')' global_name from v$instance;
set sqlprompt '&gname> '
set termout on
~~~



-- user@instance_name(hostname)

~~~shell
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
~~~







