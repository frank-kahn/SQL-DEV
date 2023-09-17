#echo "###AUTOTASK_CLIENT###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
col CLIENT_NAME for a35
set heading off
set feedback off
select client_name,status from dba_autotask_client;
exit;
EOF