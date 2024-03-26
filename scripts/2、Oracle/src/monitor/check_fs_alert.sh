#!/bin/sh
#check_fs_alert.sh

JOBS_PWD=$HOME/jobs
for i in `df -lh|awk '{printf("%d \n",$5)}'`   ##不通版本os可能不同
do
  if [[ i -ge 85 ]]     ##阈值根据需要调整
  then
    df -lh|mailx -s "`hostname` filesystem capacity Alert" `cat $JOBS_PWD/dba_mail.addr`
    exit
  fi
done