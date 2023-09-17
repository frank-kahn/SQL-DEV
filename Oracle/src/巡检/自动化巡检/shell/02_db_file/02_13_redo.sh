#echo "###REDO LOG名称####"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 200
col member for a50
set heading off
select member from v\$logfile order by group#;
exit;
EOF
