#echo "###DBA_SCHEDULER_JOBS###"
#su - oracle  -c"
sqlplus -S / as sysdba <<EOF
set line 100
col start_date for a20
set heading off
set feedback off
select 
owner,
job_name,
--job_type,
start_date
--state 
from 
dba_scheduler_jobs 
WHERE OWNER NOT IN('SYS','ORACLE_OCM','EXFSYS');
exit;
EOF
