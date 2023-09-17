#echo "###实例状态###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set heading off
select 
status 
from 
gv\$instance;
exit;
EOF
