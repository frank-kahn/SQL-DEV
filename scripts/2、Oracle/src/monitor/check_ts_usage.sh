#!/bin/bash
#
#name: check_ts_usage.sh
#purpose: check tablespace usage
#2022-06-24 add by norton


  rm -f /tmp/check_ts_usage.html

  ORACLE_SID=orcl  ##oracle sid
  export ORACLE_SID
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1  ##oracle home
  export ORACLE_HOME
  HOST_NAME=`uname -n`
  export HOST_NAME
  JOB_PWD=$HOME/jobs
  export JOB_PWD

  $ORACLE_HOME/bin/sqlplus -s "/ as sysdba"<<!
    @$JOB_PWD/check_ts_usage 
    exit
!

  var=`cat /tmp/check_ts_usage.html|wc -l`

  #echo $var
  if [[ $var -gt 11 ]];
  then
    # echo "**********************************************************************"
    # echo "There are alerts"
    echo "Check Tablespace LWM Alert "|mailx -s "dbname Check Tablespace LWM Alert"  -a  /tmp/check_ts_usage.html `cat $JOB_PWD/dba_mail.addr|grep -v \#` 
    # echo "**********************************************************************"
    # exit
  fi
  shift
done