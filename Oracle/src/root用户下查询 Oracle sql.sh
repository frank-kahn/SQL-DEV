#root 用户下查询sql获取结果

alias so='su - oracle'
sqlplus_format=$(echo 'set heading off feedback off pagesize 0 linesize 200 verify off echo off termout off trimout on trimspool on time off timing off SQLPROMPT "SQL>";')
ORACLE_SID=dbm011
so <<-SO
   export ORACLE_SID=$ORACLE_SID
   sqlplus -S / as sysdba <<-EOF
$sqlplus_format
select name from v\\\$database ;
EOF
SO
