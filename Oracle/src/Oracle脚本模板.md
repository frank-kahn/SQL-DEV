# Oracle脚本模板

## sqlplus后台执行命令

```shell
cat > stats.sql << "EOF"
select sysdate as begin_time from dual;
begin
dbms_stats.gather_database_stats; 
end;
/
select sysdate as end_time from dual;
exit
EOF

#后台执行收集全库统计信息语句
nohup sqlplus -s "/as sysdba" @stats.sql > nohup.$ORACLE_SID.log 2>&1 &
```



## spool生成命令再执行

```shell
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
```

## spool生成命令直接执行

```shell
#!/bin/bash

export ORACLE_HOME=XXX
export ORACLE_SID=XXX

$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set heading off feedback off echo off
spool /home/oracle/test.sql
select 'create table test_t(id int);' from dual;
spool off
@/home/oracle/test.sql;
exit
EOF
```

## rman后台执行并输出日志

```shell
#准备cmdfile文件
cat > $rman_cmdfile << EOF
EOF

#后台执行脚本
nohup rman target / nocatalog cmdfile $rman_cmdfile msglog $rman_log &
```







# 参考资料

