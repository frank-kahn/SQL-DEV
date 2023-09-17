sqlplus -S "/ as sysdba " << EOF
set line 200
set heading off
select 
instance_name 
from 
gv\$instance;
exit;
EOF
