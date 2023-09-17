#echo "###临时表名称###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set heading off
set feedback off
set pagesize 50
col tablespace_name for a10
col file_name for a45
select 
       --tablespace_name,
       --file_id,
       file_name
  from dba_temp_files
 order by file_id;
exit;
EOF
