#!/bin/sh

#echo "###IP信息###"
#echo "物理IP1:192.168.0.11"
#echo "物理IP2:192.168.0.12"

#echo "###架构信息###"
#echo "Oracle RAC"

echo "###操作系统版本###"
cat /etc/redhat-release

echo "###巡检开始时间###"
date

echo "###数据库版本###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set pagesize 100
--col COMP_ID for a10
--col comp_name for a35
--col version for a15
--col status for a15
--select COMP_ID,COMP_NAME,VERSION,STATUS from DBA_REGISTRY order by COMP_ID;
select * from v\$version;
exit;
EOF

echo "###数据库补丁信息###"
cd $ORACLE_HOME/OPatch
./opatch lspatches

echo "###数据库创建时间###"
sqlplus -S "/ as sysdba " << EOF
set line 200
select dbid,name,to_char(created,'YYYY-MM-DD') created,log_mode from gv\$database;
exit;
EOF


echo "####数据库启动时间###"
sqlplus -S "/ as sysdba " << EOF
set line 200
select version,instance_name,to_char(startup_time,'YYYY-MM-DD') startup_time,status from gv\$instance;
exit;
EOF

echo "###实例状态###"
sqlplus -S "/ as sysdba " << EOF
set line 200
select instance_name,status from gv\$instance;
exit;
EOF

echo "###字符集###"
sqlplus -S "/ as sysdba " << EOF
set line 200
set pagesize 100
col PARAMETER for a20
col VALUE for a30
select PARAMETER,value from nls_database_parameters where parameter in ('NLS_CHARACTERSET');
exit;
EOF
