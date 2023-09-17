#echo "###失效对象数量###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 100
set pagesize 300
col owner for a5
col object_type for a5
set heading off
set feedback off
select owner,object_type,count(*) a
  from dba_objects
 where status = 'INVALID' group by owner,object_type;
exit;
EOF
