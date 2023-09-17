##echo "###数据库大小###"
##su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set heading off
set feedback off
select trunc(sum(bytes) / 1024 / 1024,2) as db_MB from dba_segments;
exit;
EOF
