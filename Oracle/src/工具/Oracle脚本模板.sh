#!/bin/bash

export ORACLE_HOME=XXX
export ORACLE_SID=XXX

$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set heading off feedback off echo off
spool /home/oracle/test.sql
select 'create table test_t(id int);' from dual;
spool off
exit
EOF


$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set heading off feedback off echo off
spool /home/oracle/test.log
@/home/oracle/test.sql;
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS'; 
select sysdate from dual;
spool off
exit
EOF