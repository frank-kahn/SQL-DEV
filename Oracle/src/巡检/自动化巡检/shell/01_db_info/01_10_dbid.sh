sqlplus -S "/ as sysdba" << EOF
set line 30
set heading off
select 
dbid 
from 
gv\$database;
exit;
EOF
