#echo "###SGA,PGA###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 200
col name for a20
col value for a25
set heading off
set feedback off
select name,value from v\$parameter 
where upper(name) in 
(
'MEMORY_MAX_TARGET',
'MEMORY_TARGET',
'SGA_MAX_SIZE',
'SGA_TARGET',
'SGA_TARGET',
'LARGE_POOL_SIZE'
) order by name;

exit;
EOF
