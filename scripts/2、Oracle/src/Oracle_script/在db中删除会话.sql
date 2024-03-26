--It will generate kill session statements for all snipped sessions:

select 'alter system kill session '''||sid||','||serial#||''' immediate;' from v$session where status='SNIPED' ;