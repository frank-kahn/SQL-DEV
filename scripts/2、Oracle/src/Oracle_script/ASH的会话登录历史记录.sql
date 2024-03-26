select c.username,a.SAMPLE_TIME, a.SQL_OPNAME, a.SQL_EXEC_START, a.program, a.module, a.machine, b.SQL_TEXT
from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_hist_sqltext b, dba_users c
where a.SQL_ID = b.SQL_ID(+)
and a.user_id=c.user_id
and c.username='&username'
order by a.SQL_EXEC_START asc;