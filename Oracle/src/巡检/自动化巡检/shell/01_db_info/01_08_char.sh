#echo "###字符集###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set heading off
set pagesize 100
col PARAMETER for a20
col VALUE for a30
select 
value 
from 
nls_database_parameters where parameter in ('NLS_CHARACTERSET');
exit;
EOF
