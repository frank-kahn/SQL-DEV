#echo "###对象类型和数量###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 200
col owner for a15
col object_type for a15
set heading off
set feedback off
select owner,object_type,count(*) from dba_objects where owner not in 
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
'DVSYS',
'APEX_030200',
'APEX_PUBLIC_USER',
'EXFSYS',
'FLOWS_FILES',
'MGMT_VIEW',
'OWBSYS',
'OWBSYS_AUDIT',
'SCOTT',
'SPATIAL_CSW_ADMIN_USR',
'SPATIAL_WFS_ADMIN_USR',
'SYSMAN'
) group by owner,object_type order 
by object_type,owner; 
exit;
EOF
