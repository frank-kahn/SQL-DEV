#echo "###资源限制###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 100
col r_name for a10
col ini_value for a15
col c_value for a20 for 99999
col max_value for a20 for 99999
set heading off
set feedback off
select inst_id,RESOURCE_NAME as r_name,CURRENT_UTILIZATION as c_value,MAX_UTILIZATION as max_value,INITIAL_ALLOCATION as ini_value from gv\$resource_limit where resource_name in ('processes','sessions');
exit;
EOF