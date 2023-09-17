#echo "###REDO LOG名称####"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 200
--col members for a10
--set heading off
set feedback off
select group#,members,bytes/1024/1024 size_mb from v\$log order by group#,members;
exit;
EOF
