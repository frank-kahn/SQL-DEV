#echo "###用户信息####"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 200
set pagesize 100
set heading off
set feedback off
col ACCOUNT_STATUS for a20
col default_tablespace for a15
col username for a25
select 
--username,
to_char(created,'YYYY-MM-DD') created
--default_tablespace,
--ACCOUNT_STATUS 
from dba_users 
where username not in 
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
)
order by username;
exit;
EOF
