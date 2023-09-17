##echo "###归档备份###"
##su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 150
col in_size for a10
col out_size for a10
col input_type for a20 
col e for a20
col s for a20
set heading off
set feedback off
select * from (
select 
--session_key,
--input_type,
--compression_ratio,
---INPUT_BYTES_DISPLAY in_size,
output_bytes_display out_size,
to_char(START_TIME,'YYYYMMDD HH24:MI:SS') S,
to_char(END_TIME,'YYYYMMDD HH24:MI:SS') E,
status
from v\$rman_backup_job_details where INPUT_TYPE='ARCHIVELOG'
order by S DESC
) where rownum<=10;
exit;
EOF
