#!/bin/bash
#add check instance status  norton.fan 2022-06-22
. $HOME/.bash_profile
HOST_NAME=`hostname`
#IPADDR=`ifconfig |grep "inet addr"|awk -F: 'NR==1{print substr($2,1,14)}'` ##不同版本os 这里需要调整
ORACLE_SID=abc   ##oracle sid
JOB_PWD=$HOME/jobs
export JOB_PWD

vin=`ps -ef|grep pmon|grep $ORACLE_SID|wc -l`
if [ $vin -eq 0 ]
 then
     echo " $ORACLE_SID Instance down"|mailx -s "$ORACLE_SID  instance down" `cat $JOB_PWD/dba_mail.addr|grep -v  \#`
fi
