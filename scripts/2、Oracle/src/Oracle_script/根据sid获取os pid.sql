--for rac

set lines 123
col USERNAME for a15
col OSUSER for a8
col MACHINE for a15
col PROGRAM for a20
select b.spid, a.username, a.program , a.osuser ,a.machine, a.sid, a.serial#, a.status from gv$session a, gv$process b
where addr=paddr(+) and sid=&sid;