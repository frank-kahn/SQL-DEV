select sid, sql_id,serial#, status, username, program
from v$session
where PLSQL_ENTRY_OBJECT_ID in (select object_id
from dba_objects
where object_name in ('&PROCEDURE_NAME'));