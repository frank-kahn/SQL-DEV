#echo "###DBA_JOBS###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
col INTERVAL for a35
col SCHEMA_USER for a15
col what for a30
set heading off
set feedback off
SELECT 
schema_user,
last_date
from 
dba_jobs
where schema_user not in ('APEX_030200');
exit;
EOF
