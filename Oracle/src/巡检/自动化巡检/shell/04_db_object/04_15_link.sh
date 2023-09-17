sqlplus -S / as sysdba <<EOF
set line 100
col owner for a10
col db_link for a20
set heading off
set feedback off
select owner,db_link from dba_db_links;
exit;
EOF
