##echo "###用户密码策略###"
##su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
col profile for a10
col limit for a10
col RESOURCE_NAME for a25
set heading off
set feedback off
select RESOURCE_NAME,LIMIT from dba_profiles where profile='DEFAULT' and resource_name in ('PASSWORD_LIFE_TIME','FAILED_LOGIN_ATTEMPTS');
exit;
EOF
