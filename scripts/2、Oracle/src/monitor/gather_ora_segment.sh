#!/bin/bash
#
#gather_ora_segment.sh
#For collect DB segment data(>=1M)
#gather total db 
# add by norton.fan 2022-06-20

  . $HOME/.bash_profile 
  ORACLE_SID=$1
   JOB_HOME=$HOME/jobs

  sqlplus -s "/ as sysdba" <<EOF
@$JOB_HOME/gather_ora_segment.sql
EOF
  shift