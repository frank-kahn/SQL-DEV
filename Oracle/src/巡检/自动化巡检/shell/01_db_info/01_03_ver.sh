#echo "###数据库版本###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set pagesize 100
set heading off
select version from v\$instance;
exit;
EOF
