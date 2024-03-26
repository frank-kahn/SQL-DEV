select username users, round(DISK_READS/Executions) DReadsExec,Executions Exec, DISK_READS DReads,sql_text
from gv$sqlarea a, dba_users b
where a.parsing_user_id = b.user_id
and Executions > 0
and DISK_READS > 100000
order by 2 desc;