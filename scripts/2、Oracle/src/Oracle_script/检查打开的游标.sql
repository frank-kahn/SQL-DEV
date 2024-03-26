--Current open cursor

select a.value, s.username, s.sid, s.serial#
from v$sesstat a, v$statname b, v$session s
where a.statistic# = b.statistic# and s.sid=a.sid
and b.name = 'opened cursors current';

--Max allowed open cursor and total open cursor

select max(a.value) as highest_open_cur, p.value as max_open_cur
from v$sesstat a, v$statname b, v$parameter p
where a.statistic# = b.statistic# and b.name = 'opened cursors current'
and p.name= 'open_cursors'
group by p.value;