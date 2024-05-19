# Linux下添加Oracle自启动脚本

linux环境下oracle自动启动关闭的脚本，会经常用到

1、修改/etc/oratab文件，后面的dbstart和dbshut依据这个文件启动数据

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



2、创建数据库初始化文件

~~~shell
#cp $ORACLE_BASE/admin/$ORACLE_SID/pfile/init$ORACLE_SID.ora.* $ORACLE_HOME/dbs/init$ORACLE_SID.ora
cp /u01/oracle/admin/soadb/pfile/init.ora.116201214406 /u01/oracle/product/11.2.0/dbhome_1/dbs/initsoadb.ora
~~~



3、接下来在/etc/init.d下建立系统自动启动和关机前自动关闭Oracle的脚本文件，分别如下：

添加文件

~~~shell
vim start_oracle.sh

#!/bin/bash

#this script is used to start the oracle
su - oracle -c "/u01/oracle/product/11.2.0/dbhome_1/bin/dbstart"
su - oracle -c "/u01/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start"
~~~

继续添加关机脚本：

~~~shell
vim stop_oracle.sh

#!/bin/bash
#this script is used to stop the oracle
su - oracle -c "/u01/oracle/product/11.2.0/dbhome_1/bin/lsnrctl stop"
su - oracle -c "/u01/oracle/product/11.2.0/dbhome_1/bin/dbshut"
~~~

赋权：

~~~shell
chmod a+x /etc/init.d/start_oracle.sh
chmod a+x /etc/init.d/stop_oracle.sh
~~~



4、创建随系统启动和关闭的链接：

在/etc/rc2.d下加入自动启动链接，命令如下：

~~~shell
ln -s /etc/init.d/start_oracle.sh /etc/rc.d/rc2.d/S16start_oracle
ln -s /etc/init.d/start_oracle.sh /etc/rc.d/rc3.d/S16start_oracle
ln -s /etc/init.d/start_oracle.sh /etc/rc.d/rc5.d/S16start_oracle
~~~

在/etc/rc0.d下加入自动关闭链接，接着cp这两个链接在/etc/rc.d/rcN.d(N=3,5)下各一份

~~~shell
ln -s /etc/init.d/stop_oracle.sh /etc/rc.d/rc2.d/K01stop_oracle
ln -s /etc/init.d/stop_oracle.sh /etc/rc.d/rc3.d/K01stop_oracle
ln -s /etc/init.d/stop_oracle.sh /etc/rc.d/rc5.d/K01stop_oracle
~~~

设置完毕，可以重启看看效果了。

~~~shell
reboot
ps -ef | grep ora
~~~

