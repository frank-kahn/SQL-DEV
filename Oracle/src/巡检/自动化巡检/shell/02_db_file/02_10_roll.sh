#echo "###回滚段信息###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set heading off
set feedback off
set line 150
set pagesize 150
col tablespace_name for a10
col SEGMENT_NAME for a25
set pagesize 100
select 
--owner, 
--tablespace_name, 
--segment_id, 
segment_name
--status
  from dba_rollback_segs; 
--order by 2,3;
exit;
EOF
