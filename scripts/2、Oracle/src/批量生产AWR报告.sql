set linesize 120 ;
set pagesize 0;
set long 99999;
set heading off;
set termout off;
set echo off;
set feedback off;
set timing off;

select
'spool my_awrrpt_'||snap_id||'_'||(snap_id+1)||'.html'||chr(10)||
'select output '||chr(10)||
'  from table(dbms_workload_repository.awr_report_text('||dbid||',1,'||snap_id||','||(snap_id+1)||'));'||chr(10)||
'spool off;'||chr(10)
from dba_hist_snapshot
where snap_id between 14866 and 14966 -1 and dbid=2594854151
----                  ^^^^^     ^^^^^             ^^^^^^^^^^ DB ID
----                  填入开始和结束的snapshot id
----  跑一次 ?/rdbms/admin/awrrpt.sql 就可以知道这些信息 了
 
---- 上面的空行不能删-----
spool my_awr.sql;
/
spool off ;
@my_awr.sql
---- 这里要等一段时间，多敲几下回车以保证上面的语句都执行 ---
 
exit;



https://www.cnblogs.com/killkill/archive/2011/01/01/1923809.html