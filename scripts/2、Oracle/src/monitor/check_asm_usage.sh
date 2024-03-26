#!/bin/bash
#check ASM usage
#2022-06-29 created by norton.fan


. /home/oracle/.bash_profile

  rm -f /tmp/check_ASM_usage.html

  ORACLE_SID=orcl  ##sid
  export ORACLE_SID
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1   #oracle home
  export ORACLE_HOME
  HOST_NAME=`uname -n`
  export HOST_NAME
  JOB_PWD=$HOME/jobs
  export JOB_PWD
  echo $ORACLE_HOME
  $ORACLE_HOME/bin/sqlplus "/ as sysdba"<<!
    @$JOB_PWD/check_asm_usage 
    exit
!

  var=`cat /tmp/check_ASM_usage.html|wc -l`

  #echo $var
  if [[ $var -gt 10 ]];
  then
    # echo "**********************************************************************"
    # echo "There are alerts"
   echo "check asm diskgroup usage"|mailx  -s "dbname Check ASM usage Alert" -a /tmp/check_ASM_usage.html  `cat $JOB_PWD/dba_mail.addr|grep -v \#` 
    # echo "**********************************************************************"
    # exit
  fi
  shift