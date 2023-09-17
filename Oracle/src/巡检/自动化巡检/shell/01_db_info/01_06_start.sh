#echo "####数据库启动时间###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set heading off
select 
to_char(startup_time,'YYYY-MM-DD HH24:MI:SS') startup_time 
from gv\$instance;
exit;
EOF
