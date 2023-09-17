#echo "###控制文件信息###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
col name for a55
set heading off
select name from v\$controlfile;
exit;
EOF
