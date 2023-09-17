#echo "###数据文件信息###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 200
set heading off
col tablespace_name for a20
col file_name for a65
select --tablespace_name,
       --file_name
       --file_id,
       status
       --trunc(bytes / 1024 / 1024 , 2) as FILE_MB
       --autoextensible
       --trunc(maxbytes / 1024 / 1024, 2) as MAX_MB
  from dba_data_files
 order by file_id;
exit;
EOF
