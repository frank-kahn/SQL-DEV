# 8个DBA最常用的监控Oracle数据库的常用shell脚本

本文介绍了8个常用的监控数据shell脚本。首先回顾了一些DBA常用的Unix命令，以及解释了如何通过Unix Cron来定时执行DBA脚本。网上也有好多类似的文章，但基本上都不能正常运行，花点时间重新整理了下，以后就能直接使用了。

## 8个重要的脚本来监控Oracle数据库

1. 检查实例的可用性
2. 检查监听器的可用性
3. 检查alert日志文件中的错误信息
4. 在存放log文件的地方满以前清空旧的log文件
5. 分析table和index以获得更好的性能
6. 检查表空间的使用情况
7. 找出无效的对象
8. 监控用户和事务

## DBA需要的Unix基本知识

基本的UNIX命令，以下是一些常用的Unix命令：

| 命令  | 说明                     |
| ----- | ------------------------ |
| ps    | 显示进程                 |
| grep  | 搜索文件中的某种文本模式 |
| mailx | 读取或者发送mail         |
| cat   | 连接文件或者显示它们     |
| cut   | 选择显示的列             |
| awk   | 模式匹配语言             |
| df    | 显示剩余的磁盘空间       |

以下是DBA如何使用这些命令的一些例子：

1. 显示服务器上的可用实例：

~~~shell
[oracle@testos:/home/oracle]$ ps -ef| grep smon
oracle     9987      1  0 May18 ?        00:00:06 ora_smon_testdb
oracle   100798  46697  0 13:09 pts/2    00:00:00 grep --color=auto smon
[oracle@testos:/home/oracle]$
~~~

2. 显示服务器上的可用监听器：

~~~shell
[oracle@testos:/home/oracle]$ ps -ef|grep -i listener|grep -v grep
oracle     9840      1  0 May18 ?        00:00:03 /oracle/app/oracle/product/11.2.0/db/bin/tnslsnr LISTENER -inherit
[oracle@testos:/home/oracle]$
~~~

3. 查看Oracle存档目录的文件系统使用情况

~~~shell
df -k | grep /data
~~~

4. 统计alter.log文件中的行数：

~~~shell
cat alert_PPRD10.log | wc -l
~~~

5. 列出alert.log文件中的全部Oracle错误信息：

~~~shell
grep ORA-* alert.log
~~~

6. CRONTAB基本

~~~shell
一个crontab文件中包含有六个字段：
分钟 0-59
小时 0-23
月中的第几天 1-31
月份 1 - 12
星期几 0 - 6, with 0 = Sunday
~~~

7. Unix命令或者Shell脚本

~~~shell
要编辑一个crontab文件，输入： Crontab -e
要查看一个crontab文件，输入： Crontab -l
0 4 * * 5 /dba/admin/analyze_table.ksh
30 3 * * 3,6 /dba/admin/hotbackup.ksh /dev/null 2>&1
~~~

在上面的例子中，第一行显示了一个分析表的脚本在每个星期5的4：00am运行。第二行显示了一个执行热备份的脚本在每个周三和周六的3：00a.m.运行。

## 监控数据库的常用Shell脚本

### 检查Oracle实例的可用性

oratab文件中列出了服务器上的所有数据库

~~~shell
[oracle@testos:/home/oracle]$ cat /etc/oratab
#
# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.

# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third filed indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same $ORACLE_SID are not allowed.
#
#
testdb:/oracle/app/oracle/product/11.2.0/db:Y
[oracle@testos:/home/oracle]$ 
~~~

以下的脚本检查oratab文件中列出的所有数据库，并且找出该数据库的状态（启动还是关闭）

~~~shell
###################################################################
## ckinstance.ksh ##
###################################################################
ORATAB=/etc/oratab
echo "`date` "
echo "Oracle Database(s) Status `hostname` :/n"
db=`egrep -i ":Y|:N" $ORATAB | cut -d":" -f1 | grep -v "/#" | grep -v "/*"`
pslist="`ps -ef | grep pmon`"
for i in $db ; do
echo "$pslist" | grep "ora_pmon_$i" > /dev/null 2>$1
if (( $? )); then
echo "Oracle Instance - $i: Down"
else
echo "Oracle Instance - $i: Up"
fi
done
~~~

### 检查Oracle监听器的可用性

以下有一个类似的脚本检查Oracle监听器。假如监听器停了，该脚本将会重新启动监听器

~~~shell
#####################################################################
## cklsnr.sh ##
#####################################################################
#!/bin/ksh
TNS_ADMIN=/var/opt/oracle; export TNS_ADMIN
ORACLE_SID= PPRD10; export ORACLE_SID
ORAENV_ASK=NO; export ORAENV_ASK
PATH=$PATH:/bin:/usr/local/bin; export PATH
. oraenv
DBALIST="tianlesoftware@vip.qq.com,tianlesoftware@hotmail.com";export DBALIST
cd /var/opt/oracle
rm -f lsnr.exist
ps -ef | grep PPRD10 | grep -v grep > lsnr.exist
if [ -s lsnr.exist ]
then
echo
else
echo "Alert" | mailx -s "Listener 'PPRD10' on `hostname` is down" $DBALIST
lsnrctl start PPRD10
fi
~~~

### 检查Alert日志（ORA-XXXXX）

~~~shell
####################################################################
## ckalertlog.sh ##
####################################################################
#!/bin/ksh

EDITOR=vi; export EDITOR
ORACLE_SID=PPRD10; export ORACLE_SID
ORACLE_BASE=/data/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/10.2.0; export ORACLE_HOME
LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
TNS_ADMIN=/var/opt/oracle;export TNS_ADMIN
NLS_LANG=american; export NLS_LANG
NLS_DATE_FORMAT='Mon DD YYYY HH24:MI:SS'; export NLS_DATE_FORMAT
ORATAB=/var/opt/oracle/oratab;export ORATAB
PATH=$PATH:$ORACLE_HOME:$ORACLE_HOME/bin:/usr/ccs/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/openwin/bin:/opt/bin:.; export PATH
DBALIST="tianlesoftware@vip.qq.com,tianlesoftware@hotmail.com";export DBALIST

cd $ORACLE_BASE/admin/PPRD10/bdump
if [ -f alert_PPRD10.log ]
then
mv alert_PPRD10.log alert_work.log
touch alert_PPRD10.log
cat alert_work.log >> alert_PPRD10.hist
grep ORA- alert_work.log > alert.err
fi
if [ `cat alert.err | wc -l` -gt 0 ]
then
mailx -s " PPRD10  ORACLE  ALERT  ERRORS" $DBALIST < alert.err
fi
rm -f alert.err
rm -f alert_work.log
~~~

### 清除旧的归档文件

以下的脚本将会在log文件达到90%容量的时候清空旧的归档文件：

~~~shell
#######################################################################
## clean_arch.ksh ##
#######################################################################
#!/bin/ksh
df -k | grep arch > dfk.result
archive_filesystem=`awk -F" " '{ print $6 }' dfk.result`
archive_capacity=`awk -F" " '{ print $5 }' dfk.result`

if [ $archive_capacity > 90% ]
then
echo "Filesystem ${archive_filesystem} is ${archive_capacity} filled"
# try one of the following option depend on your need
find $archive_filesystem -type f -mtime +2 -exec rm -r {} ;
tar
rman
fi
~~~

### 分析表和索引（以得到更好的性能）

以下我将展示假如传送参数到一个脚本中：

~~~shell
####################################################################
## analyze_table.sh ##
####################################################################
#!/bin/ksh
# input parameter: 1: passWord # 2: SID
if (($#<1)) then echo "Please enter 'oracle' user password as the first parameter !" exit 0
fi
if (($#<2)) then echo "Please enter instance name as the second parameter!" exit 0
fi
~~~

要传入参数以执行该脚本，输入：

~~~shell
analyze_table.sh manager oradb1
~~~

脚本的第一部分产生了一个analyze.sql文件，里面包含了分析表用的语句。脚本的第二部分分析全部的表：

~~~shell
#################################################################
## analyze_table.sh ##
#################################################################
sqlplus -s '/ as sysdba' <<EOF
set heading off
set feed off
set pagesize 200
set linesize 100
spool analyze_table.sql
select 'ANALYZE TABLE ' || owner || '.' || segment_name ||
' ESTIMATE STATISTICS SAMPLE 10 PERCENT;'
from dba_segments
where segment_type = 'TABLE'
and owner not in ('SYS', 'SYSTEM');
spool off
exit
EOF
sqlplus -s '/ as sysdba' <<EOF
@./analyze_table.sql
exit
EOF
~~~

### 检查表空间的使用

以下的脚本检测表空间的使用。假如表空间只剩下10%，它将会发送一个警告email。

~~~shell
#####################################################################
## ck_tbsp.sh ##
#####################################################################
#!/bin/ksh

EDITOR=vi; export EDITOR
ORACLE_SID=PPRD10; export ORACLE_SID
ORACLE_BASE=/data/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/10.2.0; export ORACLE_HOME
LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
TNS_ADMIN=/var/opt/oracle;export TNS_ADMIN
NLS_LANG=american; export NLS_LANG
NLS_DATE_FORMAT='Mon DD YYYY HH24:MI:SS'; export NLS_DATE_FORMAT
ORATAB=/var/opt/oracle/oratab;export ORATAB
PATH=$PATH:$ORACLE_HOME:$ORACLE_HOME/bin:/usr/ccs/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/openwin/bin:/opt/bin:.; export PATH
DBALIST="tianlesoftware@vip.qq.com,tianlesoftware@hotmail.com";export DBALIST


sqlplus -s '/ as sysdba' <<EOF
set feed off
set linesize 100
set pagesize 200
column "USED (MB)" format a10
column "FREE (MB)" format a10
column "TOTAL (MB)" format a10
column PER_FREE format a10
spool tablespace.alert
SELECT F.TABLESPACE_NAME,
TO_CHAR ((T.TOTAL_SPACE - F.FREE_SPACE),'999,999') "USED (MB)",
TO_CHAR (F.FREE_SPACE, '999,999') "FREE (MB)",
TO_CHAR (T.TOTAL_SPACE, '999,999') "TOTAL (MB)",
TO_CHAR ((ROUND ((F.FREE_SPACE/T.TOTAL_SPACE)*100)),'999')||' %' PER_FREE
FROM (
SELECT TABLESPACE_NAME,
ROUND (SUM (BLOCKS*(SELECT VALUE/1024
FROM V/$PARAMETER
WHERE NAME = 'db_block_size')/1024)
) FREE_SPACE
FROM DBA_FREE_SPACE
GROUP BY TABLESPACE_NAME
) F,
(
SELECT TABLESPACE_NAME,
ROUND (SUM (BYTES/1048576)) TOTAL_SPACE
FROM DBA_DATA_FILES
GROUP BY TABLESPACE_NAME
) T
WHERE F.TABLESPACE_NAME = T.TABLESPACE_NAME
AND (ROUND ((F.FREE_SPACE/T.TOTAL_SPACE)*100)) < 80;
spool off
exit
EOF
if [ `cat tablespace.alert|wc -l` -gt 0 ]
then
cat tablespace.alert > tablespace.tmp
mailx -s "TABLESPACE  ALERT  for  PPRD10" $DBALIST < tablespace.tmp
fi
~~~

警告email输出的例子如下：

~~~shell
警告email输出的例子如下：
TABLESPACE_NAME                USED (MB)  FREE (MB)  TOTAL (MB) PER_FREE                            
------------------------------ ---------- ---------- ---------- ----------                          
SYSTEM                              519        401        920     44 %                              
MILLDATA                            559        441      1,000     44 %                              
SYSAUX                              331        609        940     65 %                              
MILLREPORTS                         146        254        400     64 % 
~~~

### 查找出无效的数据库对象

~~~shell
#####################################################################
##invalid_object_alert.sh
#####################################################################
#!/bin/ksh
EDITOR=vi; export EDITOR
ORACLE_SID=PPRD10; export ORACLE_SID
ORACLE_BASE=/data/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/10.2.0; export ORACLE_HOME
LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
TNS_ADMIN=/var/opt/oracle;export TNS_ADMIN
NLS_LANG=american; export NLS_LANG
NLS_DATE_FORMAT='Mon DD YYYY HH24:MI:SS'; export NLS_DATE_FORMAT
ORATAB=/var/opt/oracle/oratab;export ORATAB
PATH=$PATH:$ORACLE_HOME:$ORACLE_HOME/bin:/usr/ccs/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/openwin/bin:/opt/bin:.; export PATH
DBALIST="tianlesoftware@vip.qq.com,tianlesoftware@hotmail.com";export DBALIST

sqlplus -s '/ as sysdba' <<EOF
set feed off
set heading off
column OWNER format a10
column OBJECT_NAME format a35
column OBJECT_TYPE format a10
column STATUS format a10
spool invalid_object.alert
SELECT OWNER, OBJECT_NAME, OBJECT_TYPE, STATUS FROM DBA_OBJECTS WHERE STATUS = 'INVALID' ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;
spool off
exit
EOF
if [ `cat invalid_object.alert | wc -l` -gt 0 ] then
mailx -s "INVALID OBJECTS for PPRD10" $DBALIST < invalid_object.alert
fi
~~~

结果演示

~~~shell
$ more invalid_object.alert

PUBLIC     ALL_WM_LOCKED_TABLES                SYNONYM    INVALID
PUBLIC     ALL_WM_VERSIONED_TABLES             SYNONYM    INVALID
PUBLIC     DBA_WM_VERSIONED_TABLES             SYNONYM    INVALID
PUBLIC     SDO_CART_TEXT                       SYNONYM    INVALID
PUBLIC     SDO_GEOMETRY                        SYNONYM    INVALID
PUBLIC     SDO_REGAGGR                         SYNONYM    INVALID
PUBLIC     SDO_REGAGGRSET                      SYNONYM    INVALID
PUBLIC     SDO_REGION                          SYNONYM    INVALID
PUBLIC     SDO_REGIONSET                       SYNONYM    INVALID
PUBLIC     USER_WM_LOCKED_TABLES               SYNONYM    INVALID
PUBLIC     USER_WM_VERSIONED_TABLES            SYNONYM    INVALID
PUBLIC     WM_COMPRESS_BATCH_SIZES             SYNONYM    INVALID
~~~

### 监视用户和事务（死锁等）

以下的脚本在死锁发生的时候发送一个警告e-mail：

~~~shell
###################################################################
## deadlock_alert.sh ##
###################################################################
#!/bin/ksh

EDITOR=vi; export EDITOR
ORACLE_SID=PPRD10; export ORACLE_SID
ORACLE_BASE=/data/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/10.2.0; export ORACLE_HOME
LD_LIBRARY_PATH=$ORACLE_HOME/lib; export LD_LIBRARY_PATH
TNS_ADMIN=/var/opt/oracle;export TNS_ADMIN
NLS_LANG=american; export NLS_LANG
NLS_DATE_FORMAT='Mon DD YYYY HH24:MI:SS'; export NLS_DATE_FORMAT
ORATAB=/var/opt/oracle/oratab;export ORATAB
PATH=$PATH:$ORACLE_HOME:$ORACLE_HOME/bin:/usr/ccs/bin:/bin:/usr/bin:/usr/sbin:/sbin:/usr/openwin/bin:/opt/bin:.; export PATH
DBALIST="tianlesoftware@vip.qq.com,tianlesoftware@hotmail.com";export DBALIST

sqlplus -s '/ as sysdba' <<EOF
set feed off
set heading off
spool deadlock.alert
SELECT SID, DECODE(BLOCK, 0, 'NO', 'YES' ) BLOCKER,
DECODE(REQUEST, 0, 'NO','YES' ) WAITER
FROM V/$LOCK
WHERE REQUEST > 0 OR BLOCK > 0
ORDER BY block DESC;
spool off
exit
EOF
if [ `cat deadlock.alert | wc -l` -gt 0 ]
then
mailx -s "DEADLOCK ALERT for PPRD10" $DBALIST < deadlock.alert
fi
~~~



## 结论

~~~shell
0,20,40 7-17 * * 1-5 /dba/scripts/ckinstance.sh > /dev/null 2>&1
0,20,40 7-17 * * 1-5 /dba/scripts/cklsnr.sh > /dev/null 2>&1
0,20,40 7-17 * * 1-5 /dba/scripts/ckalertlog.sh > /dev/null 2>&1
30 * * * 0-6 /dba/scripts/clean_arch.sh > /dev/null 2>&1
* 5 * * 1,3 /dba/scripts/analyze_table.sh > /dev/null 2>&1
* 5 * * 0-6 /dba/scripts/ck_tbsp.sh > /dev/null 2>&1
* 5 * * 0-6 /dba/scripts/invalid_object_alert.sh > /dev/null 2>&1
0,20,40 7-17 * * 1-5 /dba/scripts/deadlock_alert.sh > /dev/null 2>&1
~~~

通过以上的脚本，可大大减轻你的工作。你可以使用这些是来做更重要的工作，例如性能调整。



# 参考资料

https://blog.51cto.com/cndba/5643036
