#echo "###数据库创建时间###"
sqlplus -S "/ as sysdba " << EOF
set heading off
set line 200
select 
to_char(created,'YYYY-MM-DD HH24:MI:SS') created
from gv\$database;
exit;
EOF
