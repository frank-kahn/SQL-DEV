--for Single

select 'alter system kill session ' ||''''||SID||','||SERIAL#||' immediate ;' from v$session
where sql_id='&sql_id';

--for RAC

select 'alter system kill session ' ||''''||SID||','||SERIAL#||',@'||inst_id||''''||' immediate ;'
from gv$session where sql_id='&sql_id'