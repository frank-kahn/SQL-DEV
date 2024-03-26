select state,UNDOBLOCKSDONE,UNDOBLOCKSTOTAL,
UNDOBLOCKSDONE/UNDOBLOCKSTOTAL*100
from gv$fast_start_transactions;

alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo",
decode(cputime,0,'unknown',
sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) "预估完成时间"
from v$fast_start_transactions;

select a.sid, a.username, b.xidusn, b.used_urec, b.used_ublk
from v$session a, v$transaction b
where a.saddr=b.ses_addr
order by 5 desc;