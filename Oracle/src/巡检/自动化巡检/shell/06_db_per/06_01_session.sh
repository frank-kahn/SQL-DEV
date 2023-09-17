##echo "###会话信息###"
##su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 300
col username for a15
set heading off
set feedback off
select inst_id, username, count(*)
  from gv\$session
 group by inst_id, username
 order by 1;
exit;
EOF