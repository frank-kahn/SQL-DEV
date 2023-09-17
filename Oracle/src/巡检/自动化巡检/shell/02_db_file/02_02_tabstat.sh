#echo "###表空间状态###"
#su - oracle  -c"
#sqlplus -S \"/ as sysdba \" << EOF
sqlplus -S "/ as sysdba " << EOF
set line 300
set pagesize 100
set heading off
set feedback off
col status for a10
col tablespace_name for a20
select status
  --tablespace_name
  from dba_tablespaces
where tablespace_name not in ('TEMP')
;
exit;
EOF
