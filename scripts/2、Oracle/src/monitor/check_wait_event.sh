#!/bin/bash
#
#name: check_wait_event.sh
#purpose: check wait event
#2023-08-1 add by norton

  rm -f /tmp/check_wait_event.html

  ORACLE_SID=orcl   ##sid
  export ORACLE_SID
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1  ##oracle home
  export ORACLE_HOME
  HOST_NAME=`uname -n`
  export HOST_NAME
  JOB_PWD=$HOME/jobs
  export JOB_PWD

  $ORACLE_HOME/bin/sqlplus -s "/ as sysdba"<<!
    @$JOB_PWD/check_wait_event 
    exit
!

  var=`cat /tmp/check_wait_event.html|wc -l`

  #echo $var
  if [[ $var -gt 11 ]];
  then
    # echo "**********************************************************************"
    # echo "There are alerts"
    echo "please contact DBA"|mailx -s "dbname Check Wait Event Alert"  -a  /tmp/check_wait_event.html `cat $JOB_PWD/base_mail.addr|grep -v \#` 
    # echo "**********************************************************************"
    # exit
  fi
  shift
done