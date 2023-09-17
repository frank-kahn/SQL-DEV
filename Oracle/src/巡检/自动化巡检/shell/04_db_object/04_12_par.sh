#echo "###分区表信息###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 100
set pagesize 300
col owner for a10
col TABLE_NAME for a20
set heading off
set feedback off
SELECT 
OWNER,
TABLE_NAME,
PARTITIONING_TYPE 
FROM 
DBA_PART_TABLES 
WHERE OWNER NOT IN 
(
'SYS',
'SYSTEM',
'SYSDG',
'SYSKM',
'SYSRAC',
'SYSBACKUP',
'AUDSYS',
'OUTLN',
'GSMROOTUSER',
'GSMUSER',
'GSMADMIN_INTERNAL',
'DIP',
'XS\$NULL',
'REMOTE_SCHEDULER_AGENT',
'DBSFWUSER',
'ORACLE_OCM',
'SYS\$UMF',
'DGPDB_INT',
'DBSNMP',
'APPQOSSYS',
'GSMCATUSER',
'GGSYS',
'XDB',
'ANONYMOUS',
'WMSYS',
'OJVMSYS',
'CTXSYS',
'ORDDATA',
'ORDSYS',
'ORDPLUGINS',
'SI_INFORMTN_SCHEMA',
'OLAPSYS',
'MDDATA',
'MDSYS',
'LBACSYS',
'DVF',
'DVSYS'
) ORDER BY 1;
exit;
EOF
