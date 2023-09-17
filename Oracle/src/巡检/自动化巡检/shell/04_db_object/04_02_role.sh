#echo "###DBA角色###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
col GRANTEE for a10
set heading off
set feedback off
select grantee from dba_role_privs where GRANTED_ROLE='DBA' and grantee not in ('SYS','SYSTEM');
exit;
EOF
