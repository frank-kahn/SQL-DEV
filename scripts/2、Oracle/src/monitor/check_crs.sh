#!/bin/bash
#purpose: check crs status and send mail
#2022-06-27 check crs status
   . /home/grid/.bash_profile
IPADDR=`ifconfig |grep "inet addr:10"|awk -F: 'NR==1{print substr($2,1,14)}'` ##不同版本os 这里不同
  export IPADDR
JOB_HOME=/home/grid/jobs
  export JOB_HOME
chkcrs=`crs_stat -t -v|grep -c OFFLINE`  ##11g
##chkcrs=`crsctl stat res -t|grep -c OFFLINE`  ##19c
    if [  $chkcrs -gt 3 ] ##11g
    ##if [  $chkcrs -gt 6 ] ##19c
    then
      crs_stat -t -v|egrep -v "gsd"|grep OFFLINE>/tmp/crs_off.log
      echo "Please contact DBA   immediately TEL: ">>/tmp/crs_off.log
      cat  /tmp/crs_off.log|mail -s "$IPADDR jxmes Check crs status" `cat $JOB_HOME/dba_mail.addr|grep -v \#`
      >/tmp/crs_off.log
    elif [  $chkcrs -eq 0 ]
      then
     echo "CRS DOWN Please contact DBA  immediately TEL "|mail -s "$IPADDR dbname Check crs status" `cat $JOB_HOME/dba_mail.addr|grep -v \#`
    fi    
  shift