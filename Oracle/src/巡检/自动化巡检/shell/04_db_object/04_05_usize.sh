#echo "####用户数据大小####"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
col owner for a10
set pagesize 100
set heading off
set feedback off
select owner, trunc(sum(bytes) / 1024 / 1024,2) as db_MB
  from dba_segments
where owner not in
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
'XS$NULL',
'REMOTE_SCHEDULER_AGENT',
'DBSFWUSER',
'ORACLE_OCM',
'SYS$UMF',
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
'DVSYS',
'SYSMAN',
'APEX_030200',
'SCOTT',
'EXFSYS'
)
 group by owner
 order by db_MB;
exit;
EOF
