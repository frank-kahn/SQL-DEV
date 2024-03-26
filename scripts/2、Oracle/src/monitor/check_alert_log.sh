#!/bin/bash
#check alert log by norton.fan

    . /home/oracle/.bash_profile 

  ORACLE_SID=orcldb1  ##sid
  export ORACLE_SID
  ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1   ##oracle home
  export ORACLE_HOME
  HOST_NAME=`uname -n`
  export HOST_NAME
  JOB_HOME=$HOME/jobs
  export JOB_HOME
  DUMP_DEST=/u01/app/oracle/diag/rdbms/btmesdb/"$ORACLE_SID"/trace
  export DUMP_DEST
  IPADDR=`ifconfig |grep "inet"|awk -F: 'NR==1{print substr($1,13,13)}'`  ##不通版本os 这里可能需要修改
  export IPADDR
  LOG_NAME="alert_$ORACLE_SID.log"
  CHECK_LINES=50
  ERR_MSG="ORA-|Failure|alter|unusable|shutdown|startup"
  ERR_EXC="ORA-02068|ORA-03113|ORA-02050|ORA-12012|ORA-06512|ORA-12541|ORA-12005|ORA-03113|ORA-02396|ORA-02063|ORA-01012|ORA-000060|ORA-02054|ORA-12535|ORA-02053|ORA-01013|ORA-3136|ORA-03135"
  OLD_LOG_1=`echo "old_1_$ORACLE_SID.log"`
  OLD_LOG_2=`echo "old_2_$ORACLE_SID.log"`
  export LOG_NAME CHECK_LINES ERR_MSG OLD_LOG_1 OLD_LOG_2 ERR_EXC
  tail -$CHECK_LINES $DUMP_DEST/$LOG_NAME|egrep -i $ERR_MSG|egrep -v $ERR_EXC|egrep -v "ALTER DATABASE BACKUP CONTROLFILE"|egrep -v "ALTER SYSTEM ARCHIVE LOG" > /tmp/new.log
  num=`cat /tmp/new.log |wc -l`
  if [ $num -gt 0 ]
  then
    if [ ! -f /tmp/$OLD_LOG_1 ]
    then
      touch /tmp/$OLD_LOG_1
    fi

    if [ ! -f /tmp/$OLD_LOG_2 ]
    then
      touch /tmp/$OLD_LOG_2
    fi

    if [ `cat /tmp/$OLD_LOG_2|wc -l` -eq 0 ]
    then
      var=$num
    else
      cmp -s /tmp/new.log /tmp/$OLD_LOG_2
      var=$?
    fi
if [ $var -ge 1 ]
    then
      # echo "**********************************************************************"
      # echo "There are alerts"
      tail -$CHECK_LINES $DUMP_DEST/$LOG_NAME|mail -s "$IPADDR btmes_81 Check Alert Log" `cat $JOB_HOME/dba_mail.addr|grep -v \#`   ##dba_mail.addr存放邮件地址
       echo "**********************************************************************"
      cp /tmp/$OLD_LOG_1 /tmp/$OLD_LOG_2
      cp /tmp/new.log /tmp/$OLD_LOG_1
    fi
  else
    >/tmp/$OLD_LOG_1
    >/tmp/$OLD_LOG_2
  fi
  shift
