#!/bin/bash
ORACLE_BASE=/oracle/app/oracle; export ORACLE_BASE
ORACLE_HOME=/oracle/app/oracle/product/11.2.0; export ORACLE_HOME
ORACLE_SID=db01; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH
FOLDER=/tmp/log_tmp
REPORT_FOLDER=/tmp/log_tmp
SQL_FILE_NAME=$FOLDER/GET_SNAP_ID.sql;
OUT_FILE_NAME=$FOLDER/GET_SNAP_ID.out;
START_FLAG="'start snap_id:'";
END_FLAG="'end snap_id:'";
START_ID='';
END_ID='';
REPORT_TYPE="'html'";
HOST_NAME=`hostname`;
REPORT_FILE_TMP=`date +%Y_%m_%d`;
REPORT_FILE="awrrpt_"$HOST_NAME"_"$REPORT_FILE_TMP".html";
REPORT_NAME="'"$REPORT_FOLDER"/"$REPORT_FILE"'";
#echo $REPORT_NAME $REPORT_TYPE
DEST_IP="192.168.1.10";
echo "set linesize 40">$SQL_FILE_NAME;
echo "set pagesize 800">>$SQL_FILE_NAME;
echo "set echo off">>$SQL_FILE_NAME;
echo "set heading off">>$SQL_FILE_NAME;
echo "set feedback off">>$SQL_FILE_NAME;
echo "spool $OUT_FILE_NAME">>$SQL_FILE_NAME;
echo "var curdate varchar2(20);">>$SQL_FILE_NAME;
echo "var startid varchar2(20);">>$SQL_FILE_NAME;
echo "var endid varchar2(20);">>$SQL_FILE_NAME;
echo "begin ">>$SQL_FILE_NAME;
echo "select to_char(sysdate-1,'DD-MON-YY') into :curdate from dual;">>$SQL_FILE_NAME;
echo ":curdate := concat('%',concat(:curdate,'%'));">>$SQL_FILE_NAME;
echo "select min(SNAP_ID) min, max(SNAP_ID) max into :startid, :endid ">>$SQL_FILE_NAME;
echo "from WRM\$_SNAPSHOT">>$SQL_FILE_NAME;
echo "where END_INTERVAL_TIME like :curdate;">>$SQL_FILE_NAME;
echo ":startid := concat($START_FLAG, :startid);">>$SQL_FILE_NAME;
echo ":endid := concat($END_FLAG, :endid);">>$SQL_FILE_NAME;
echo "end;">>$SQL_FILE_NAME; 
echo "/">>$SQL_FILE_NAME;
echo "print :startid;">>$SQL_FILE_NAME;
echo "print :endid;">>$SQL_FILE_NAME;
echo "spool off;">>$SQL_FILE_NAME;
sqlplus /nolog <<EOF >/dev/null;
conn / as sysdba;
@$SQL_FILE_NAME;
exit;
EOF
START_ID=`cat $OUT_FILE_NAME|awk -F ':' '$0~/start/{print $2}'`;
END_ID=`cat $OUT_FILE_NAME|awk -F ':' '$0~/end/{print $2}'`;
#echo $START_ID"   "$END_ID;
sqlplus /nolog<<EOF >/dev/null;
conn / as sysdba
define  begin_snap   = $START_ID;
define  end_snap     = $END_ID;
define  report_type  = $REPORT_TYPE;
define report_name   = $REPORT_NAME;
@?/rdbms/admin/awrrpt;
exit;
EOF

