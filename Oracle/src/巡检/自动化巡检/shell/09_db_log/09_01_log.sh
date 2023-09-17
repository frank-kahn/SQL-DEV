#echo "###检查数据库告警日志###"
BASE=`cat /home/oracle/.bash_profile |grep ORACLE_BASE|awk -F "=" '{print $2}'`
tail -1000 $BASE/diag/rdbms/*/*/trace/alert_*.log|grep ORA-|sort -u
