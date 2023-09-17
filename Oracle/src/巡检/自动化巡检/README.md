# Oracle自动巡检使用说明

## 脚本目录结构

~~~shell
[oracle@testos:/home/oracle]$tree /home/oracle/dbcheck/scripts
/home/oracle/dbcheck/scripts
├── 00_db_input
│   ├── 00_01_master.sh
│   ├── 00_02_slave.sh
│   ├── 00_03_vip.sh
│   ├── 00_04_arc.sh
│   ├── 00_05_name.sh
│   ├── 00_06_time.sh
│   ├── 00_07_title.sh
│   ├── 00_08_word.sh
│   └── 00.sh
├── 01_db_info
│   ├── 01_01_os.sh
│   ├── 01_02_time.sh
│   ├── 01_03_ver.sh
│   ├── 01_04_path.sh
│   ├── 01_05_cre.sh
│   ├── 01_06_start.sh
│   ├── 01_07_ins.sh
│   ├── 01_08_char.sh
│   ├── 01_09_insname.sh
│   ├── 01_10_dbid.sh
│   ├── 01_11_port.sh
│   ├── 01_db_info.sh
│   └── 01.sh
├── 02_db_file
│   ├── 02_01_name.sh
│   ├── 02_02_tabstat.sh
│   ├── 02_03_total.sh
│   ├── 02_04_use.sh
│   ├── 02_05_file.sh
│   ├── 02_06_auto.sh
│   ├── 02_07_max.sh
│   ├── 02_08_state.sh
│   ├── 02_09_name.sh
│   ├── 02_10_roll.sh
│   ├── 02_11_temp.sh
│   ├── 02_12_con.sh
│   ├── 02_13_redo.sh
│   ├── 02_14_redo.sh
│   ├── 02_15_swi.sh
│   └── 02.sh
├── 03_db_rac
│   ├── 03_01_asm.sh
│   ├── 03_02_asmdisk.sh
│   ├── 03_03_ocr.sh
│   ├── 03_04_ocrcheck.sh
│   ├── 03_05_ocrbak.sh
│   ├── 03_06_vote.sh
│   ├── 03_07_clu.sh
│   ├── 03_08_res.sh
│   ├── 03_09_scan.sh
│   ├── 03_10_lis.sh
│   └── 03.sh
├── 04_db_object
│   ├── 04_01_ao.sh
│   ├── 04_02_role.sh
│   ├── 04_03_pass.sh
│   ├── 04_04_size.sh
│   ├── 04_05_usize.sh
│   ├── 04_06_username.sh
│   ├── 04_07_usertime.sh
│   ├── 04_08_usertab.sh
│   ├── 04_09_userstat.sh
│   ├── 04_10_object.sh
│   ├── 04_11_inv.sh
│   ├── 04_12_par.sh
│   ├── 04_13_job.sh
│   ├── 04_14_sch.sh
│   ├── 04_15_link.sh
│   └── 04.sh
├── 05_db_bakchk
│   ├── 05_01_fullbak.sh
│   ├── 05_02_levelbak.sh
│   ├── 05_03_archbak.sh
│   ├── 05_04_rman.sh
│   ├── 05_db_bakchk.sh
│   └── 05.sh
├── 06_db_per
│   ├── 06_01_session.sh
│   ├── 06_02_res.sh
│   ├── 06_03_task.sh
│   ├── 06_04_sga.sh
│   ├── 06_05_event.sh
│   ├── 06_06_free.sh
│   ├── 06_07_memuse.sh
│   ├── 06_08_cpuuse.sh
│   └── 06.sh
├── 07_db_para
│   ├── 07_01_para.sh
│   └── 07.sh
├── 08_db_os
│   ├── 08_01_df.sh
│   ├── 08_02_mount.sh
│   ├── 08_03_fstab.sh
│   └── 08.sh
└── 09_db_log
    ├── 09_01_log.sh
    ├── 09_02_message.sh
    └── 09.sh

10 directories, 89 files
[oracle@testos:/home/oracle]$
~~~



## 脚本说明

### 文件夹说明

| 脚本文件夹名 | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| 00_db_input  | 00_db_input脚本，是用来进行交互式的脚本，也就是交互式的输入IP信息、巡检时间、巡检报告名称等信息，仅供参考 |
| 01_db_info   | 数据库基础信息包括：操作系统版本、当前时间、数据库版本、数据库补丁版本、数据库创建时间、数据库启动时间、实例状态、字符集、数据库名、DBID、端口号。 |
| 02_db_file   | 数据库文件信息                                               |
| 03_db_rac    | 数据库集群信息，如果只有Oracle单实例环境，跳过shell执行阶段  |
| 04_db_object | 数据库对象信息                                               |
| 05_db_bakchk | 数据库备份信息                                               |
| 06_db_per    | 数据库性能信息                                               |
| 07_db_para   | 数据库参数如果配置不合理，将会导致数据库不稳定，甚至宕机、丢失数据等。<br/>然而由于每套库对应业务不同，参数配置也会略有差异，需要结果自身的业务特点，配置适合的数据库参数。<br/>数据库是否需要开启自带的审计功能，如果不是，请关闭audit_trail。<br/>数据库是否需要密码延时特性，如果不是，需要配置28401  event，关闭该特性。<br/>数据库是否需要延时段创建特性，如果不是，需要关闭deferred_segment_creation。<br/>数据库是否需要基数反馈特性，如果不是，需要关闭_optimizer_use_feedback。<br/>在我们设置数据库参数时，需要理解每个参数的作用，以及每个参数开启或关闭的影响。 |
| 08_db_os     | 数据库系统信息<br>即使使用的是RAC数据库，检查数据库服务器本地磁盘使用率也是尤为重要，因为OLR、数据库日志等信息还是需要存在本地磁盘，如果空间不足，数据库也会出现问题。<br/>巡检时为什么需要检查磁盘挂载情况和挂载情况呢？<br/>假如数据库服务器操作系统发生了重启，如何判断需要数据库需要的盘都已经自动挂载了，如果没有自动挂载，你是否可以快速手动挂载呢？这就需要你非常清楚数据库库相关磁盘的挂载信息。<br/>除此以外，在检查/etc/fstab自动挂载信息时，需要确保每一项都是正确的，如果配置文件有问题，例如写入了不存在的磁盘信息，可能会导致操作系统无法正常启动。 |
| 09_db_log    | 数据库日志信息                                               |

### 脚本说明

| 脚本名称          | 说明                                                         |
| ----------------- | ------------------------------------------------------------ |
| 00.sh             | 调用执行00脚本                                               |
| 00_01_master.sh   | 实例1 IP                                                     |
| 00_02_slave.sh    | 实例2 IP                                                     |
| 00_03_vip.sh      | VIP                                                          |
| 00_04_arc.sh      | 架构：Oracle RAC/Oracle one Node                             |
| 00_05_name.sh     | 名字                                                         |
| 00_06_time.sh     | 巡检时间                                                     |
| 00_07_title.sh    | xxx巡检                                                      |
| 00_08_word.sh     | xxx巡检报告.docx                                             |
| 01.sh             | 调用执行01脚本                                               |
| 01_01_os.sh       | 查看数据库服务器操作系统版本。<br>命令只适用redhat、oracle  Linux等操作系统，不适用suse、aix、等操作系统，可以根据不同系统调整对应的命令。 |
| 01_02_time.sh     | 查看巡检当前时间                                             |
| 01_03_ver.sh      | 查看数据库统版本。<br/>其中 heading off表示去掉标题，v$instance中$是特殊符号，需要用\转义。 |
| 01_04_path.sh     | 数据库补丁信息                                               |
| 01_05_cre.sh      | 查看数据库创建时间                                           |
| 01_06_start.sh    | 查看数据库启动时间。<br/>数据库重启是一个比较重大的操作，如何了解到数据库近期是否发生过重启，除了监控、告警日志，也可以查看数据库最近一次启动时间，如果并不是你熟悉的启动时间，需要排查数据库近期是否发生过故障自动重启。 |
| 01_07_ins.sh      | 查看数据库实例状态。<br/>如果是RAC，将会出现所有实例的状态，确保实例状态是OPEN。 |
| 01_08_char.sh     | 查看数据库字符集                                             |
| 01_09_insname.sh  | 查看实例名称                                                 |
| 01_10_dbid.sh     | 查看数据库dbid                                               |
| 01_11_port.sh     | 检查数据库监听端口信息。<br/>检查监听端口，其中awk取出port端口号部分，sed删除掉多余的右括号。 |
| 01_db_info.sh     | 01部分脚本合并后的文件                                       |
| 02.sh             | 调用执行02脚本                                               |
| 02_01_name.sh     | 查询表空间名称                                               |
| 02_02_tabstat.sh  | 查询表空间状态。<br/>查询表空间状态，确保都是ONLINE状态。    |
| 02_03_total.sh    | 查询表空间总大小                                             |
| 02_04_use.sh      | 查询表空间使用率，如果使用率较高，还需要检查数据文件是否自动扩展，是否达到自动扩展最大值，磁盘空间是否充足等，在考虑是否需要扩容表空间。 |
| 02_05_file.sh     | 查询数据文件总大小                                           |
| 02_06_auto.sh     | 查询数据文件是否开启自动扩展，通常不建议数据文件开启自动扩展，性能和监控性较差。 |
| 02_07_max.sh      | 查询数据文件自动扩展最大值，8k数据块，普通表空间下，单个数据文件最大可扩展到32G，如果没有开启自动扩展，maxbytes显示为0. |
| 02_08_state.sh    | 查询数据文件状态，确保都是AVAILABLE状态。                    |
| 02_09_name.sh     | 查询数据文件路径和名称，RAC环境需要特别关注，确保数据文件创建在ASM共享存储上，而不是本地文件系统上。 |
| 02_10_roll.sh     | 查询回滚段名称。<br/>之前处理过一次UNDO段头出现坏块导致数据库宕机的故障，处理故障最关键的一步是需要在数据库无法open的情况下找到所有回滚段的名称，并加到隐含参数里跳过回滚段的检查，方法有多种，strings或bbed都可以，当时使用的bbed，花费了一些时间才搞定，从此以后，每次巡检都会将回滚段名称记录下来。 |
| 02_11_temp.sh     | 查询临时文件，确保数据库存在临时文件，特别是在重建DG备库，或重建控制文件后，需要手动创建临时文件。 |
| 02_12_con.sh      | 查询控制文件路径和名称,通常控制文件应该有多个，并且在不同目录下。 |
| 02_13_redo.sh     | 查询redo log file路径和名称                                  |
| 02_14_redo.sh     | 查询日志组成员数量，大小                                     |
| 02_15_swi.sh      | 查询最近5天日志切换频率，如果出现归档激增问题，需要检查是否正常。 |
| 03.sh             | 调用执行03脚本                                               |
| 03_01_asm.sh      | 查询ASM磁盘组信息                                            |
| 03_02_asmdisk.sh  | 查询ASM磁盘信息                                              |
| 03_03_ocr.sh      | 查询ocr配置信息ocrcheck -config                              |
| 03_04_ocrcheck.sh | 查询ocr状态信息，确保无报错ocrcheck                          |
| 03_05_ocrbak.sh   | 查询ocr备份信息ocrconfig -showbackup                         |
| 03_06_vote.sh     | 查询votedisk信息crsctl query css votedisk                    |
| 03_07_clu.sh      | 查询集群信息crsctl check cluster -all                        |
| 03_08_res.sh      | 查询集群资源信息,重点关注资源是否ONLINE,实例是否OPEN。crsctl stat res -t |
| 03_09_scan.sh     | 查询scan状态srvctl status scan                               |
| 03_10_lis.sh      | 查询监听状态srvctl status listener                           |
| 04.sh             | 调用执行04脚本                                               |
| 04_01_ao.sh       | 查询异常对象，根据对象名进行匹配，如果匹配到任何对象，你的数据库可能已经感染勒索病毒或被恶意攻击了。 |
| 04_02_role.sh     | 查询拥有DBA角色的用户，通常情况下， 对用户授权应该采用最小权限原则，不建议直接授予DBA角色权限。 |
| 04_03_pass.sh     | 查询数据库密码策略，确保是否满足当前需求。                   |
| 04_04_size.sh     | 查询数据库总大小，作为DBA需要清除每套数据库大概数据量，如果有激增，需要排查是否有影响。 |
| 04_05_usize.sh    | 查询业务用户数据量。                                         |
| 04_06_username.sh | 查询业务用户名，DBA通常需要清除，每套数据库上每个用户对应什么业务。 |
| 04_07_usertime.sh | 查询业务用户创建时间                                         |
| 04_08_usertab.sh  | 查询业务用户默认表空间，通常每个业务用户，应该有一个独立的默认表空间。 |
| 04_09_userstat.sh | 查询业务用户状态，确保都是OPEN状态。                         |
| 04_10_object.sh   | 查询业务用户对象类型和数量。                                 |
| 04_11_inv.sh      | 查询失效的对象。                                             |
| 04_12_par.sh      | 查询业务用户分区表信息，确保不会出现由于没有及时添加分区，导致数据无法写入的问题。 |
| 04_13_job.sh      | 查询业务用户job信息，在数据库日常维护时，需要考虑是否会影响到job运行。 |
| 04_14_sch.sh      | 查询业务用户scheduler_jobs 信息，在数据库日常维护时，需要考虑是否会影响到scheduler_jobs运行。 |
| 04_15_link.sh     | 查询业务用户dblinks信息。                                    |
| 05.sh             | 调用执行05脚本                                               |
| 05_01_fullbak.sh  | 查询数据库全备信息，备份文件输出大小，备份开始时间，结束时间，备份状态。 |
| 05_02_levelbak.sh | 查询数据库增量备份信息，备份文件输出大小，备份开始时间，结束时间，备份状态。 |
| 05_03_archbak.sh  | 查询数据库归档备份信息                                       |
| 05_04_rman.sh     | 查询数据库rman配置信息                                       |
| 05_db_bakchk.sh   | 05四个脚本合并                                               |
| 06.sh             | 调用执行06脚本                                               |
| 06_01_session.sh  | 查询会话信息，每个用户连接会话数。                           |
| 06_02_res.sh      | 会话资源使用情况，包括最大可用会话数，当前会话数，曾经达到过的最大值等，通常根据这个值能大概判断出当前配置的processes、session是否够用，特别是在RAC环境下，当因为某些原因，需要关停某一个节点时，需要考虑另一个节点的processes,session是否够用。 |
| 06_03_task.sh     | 数据库自带的三个任务，功能不稳定，BUG较多，建议根据实际情况考虑是否关闭。auto optimizer stats  collection 、auto space advisor、 sql tuning advisor |
| 06_04_sga.sh      | sga配置信息，当数据库服务器内存使用率过高，或数据库命中率较低可以考虑是否SGA配置不合理。 |
| 06_05_event.sh    | 查询当前等待事件值，定位Oracle数据库问题时，经常会去检查数据库等待事件信息，它能帮助我们快速定位数据库瓶颈点，进而分析故障的根本原因。 |
| 06_06_free.sh     | 查询数据库服务器内存信息，包括内存总大小，剩余大小，活跃部分大小，非活跃部分大小等。 |
| 06_07_memuse.sh   | 查询数据库服务器占用内存最高的前10个进程。                   |
| 06_08_cpuuse.sh   | 查询数据库服务器占用CPU最高的前10个进程。                    |
| 07.sh             |                                                              |
| 07_01_para.sh     | 通过case when方式，判断哪些参数不是CORRECT，并将这部分参数记录下来，输出到巡检报告里。 |
| 08.sh             |                                                              |
| 08_01_df.sh       | 检查磁盘使用率                                               |
| 08_02_mount.sh    | 检查磁盘挂载情况                                             |
| 08_03_fstab.sh    | 检查自动挂载信息                                             |
| 09.sh             |                                                              |
| 09_01_log.sh      | alert日志                                                    |
| 09_02_message.sh  | 操作系统message日志                                          |





## 配置巡检环境

~~~shell
su - oracle
mkdir -p /home/oracle/dbcheck/{scripts,log,tmp}
#上传脚本到scripts（并检查好权限）
chown -R oracle:oinstall /home/oracle/dbcheck
#创建存放log的空目录
mkdir -p /home/oracle/dbcheck/log/{00_db_input,01_db_info,02_db_file,03_db_rac,04_db_object,05_db_bakchk,06_db_per,07_db_para,08_db_os,09_db_log}
~~~

## 巡检步骤

### 顺序执行shell脚本（root用户执行）

~~~shell
#00
[root@testos ~]# sh /home/oracle/dbcheck/scripts/00_db_input/00.sh
开始执行脚本 ...
开始执行01脚本 ...
Enter Master IP:192.168.1.59
开始执行02脚本 ...
Enter Slave IP:
开始执行03脚本 ...
Enter VIP:
开始执行04脚本 ...
Enter DB Architecture:Oracle one Node
开始执行05脚本 ...
Enter You Name:yaokang
开始执行06脚本 ...
开始执行07脚本 ...
Enter You titile:testdb_check
开始执行08脚本 ...
Enter You Word Document Name:testdb_check.docx
脚本执行结束 ...
[oracle@testos:/home/oracle]$

#01
[root@testos ~]# sh /home/oracle/dbcheck/scripts/01_db_info/01.sh
数据库信息查询 开始 ...
Sun Sep 17 19:13:18 CST 2023
Sun Sep 17 19:13:20 CST 2023
数据库信息查询 结束 ...

#02
[root@testos ~]# sh /home/oracle/dbcheck/scripts/02_db_file/02.sh
数据库文件查询 开始 ...
Sun Sep 17 19:14:30 CST 2023
查询结束 ...
[root@testos ~]# 

#03 为rac环境检查项目，当前测试环境为单机环境，跳过

#04
[root@testos ~]# sh /home/oracle/dbcheck/scripts/04_db_object/04.sh
04 begin ...
04 end ...
[root@testos ~]# 

#05
[root@testos ~]# sh /home/oracle/dbcheck/scripts/05_db_bakchk/05.sh
05 begin ...
05 end ...
[root@testos ~]# 

#06
[root@testos ~]# sh /home/oracle/dbcheck/scripts/06_db_per/06.sh
06 begin ...
06 end ...
[root@testos ~]# 

#07
[root@testos ~]# sh /home/oracle/dbcheck/scripts/07_db_para/07.sh
07 begin ...
07 end ...
[root@testos ~]# 

#08
[root@testos ~]# sh /home/oracle/dbcheck/scripts/08_db_os/08.sh
08 begin ...
08 end ...
[root@testos ~]#

#09
[root@testos ~]# sh /home/oracle/dbcheck/scripts/09_db_log/09.sh
09 begin ...
09 end ...
[root@testos ~]# 
~~~

### 移动执行shell生成的log文件到指定的位置

#### 查看生成的log文件

~~~shell
[root@testos ~]# tree /home/oracle/dbcheck/log
/home/oracle/dbcheck/log
├── 00_db_input
│   ├── 00_01_master.log
│   ├── 00_02_slave.log
│   ├── 00_03_vip.log
│   ├── 00_04_arc.log
│   ├── 00_05_name.log
│   ├── 00_06_time.log
│   ├── 00_07_title.log
│   └── 00_08_word.log
├── 01_db_info
│   ├── 01_01_os.log
│   ├── 01_02_time.log
│   ├── 01_03_ver.log
│   ├── 01_04_path.log
│   ├── 01_05_cre.log
│   ├── 01_06_start.log
│   ├── 01_07_ins.log
│   ├── 01_08_char.log
│   ├── 01_09_insname.log
│   ├── 01_10_dbid.log
│   └── 01_11_port.log
├── 02_db_file
│   ├── 02_01_name.log
│   ├── 02_02_tabstat.log
│   ├── 02_03_total.log
│   ├── 02_04_use.log
│   ├── 02_05_file.log
│   ├── 02_06_auto.log
│   ├── 02_07_max.log
│   ├── 02_08_state.log
│   ├── 02_09_name.log
│   ├── 02_10_roll.log
│   ├── 02_11_temp.log
│   ├── 02_12_con.log
│   ├── 02_13_redo.log
│   ├── 02_14_redo.log
│   └── 02_15_swi.log
├── 03_db_rac
├── 04_db_object
│   ├── 04_01_ao.log
│   ├── 04_02_role.log
│   ├── 04_03_pass.log
│   ├── 04_04_size.log
│   ├── 04_05_usize.log
│   ├── 04_06_username.log
│   ├── 04_07_usertime.log
│   ├── 04_08_usertabo.log
│   ├── 04_09_userstat.log
│   ├── 04_10_object.log
│   ├── 04_11_inv.log
│   ├── 04_12_par.log
│   ├── 04_13_job.log
│   ├── 04_14_sch.log
│   └── 04_15_link.log
├── 05_db_bakchk
│   ├── 05_01_fullbak.log
│   ├── 05_02_levelbak.log
│   ├── 05_03_archbak.log
│   └── 05_04_rman.log
├── 06_db_per
│   ├── 06_01_session.log
│   ├── 06_02_res.log
│   ├── 06_03_task.log
│   ├── 06_04_sga.log
│   ├── 06_05_event.log
│   ├── 06_06_free.log
│   ├── 06_07_memuse.log
│   └── 06_08_cpuuse.log
├── 07_db_para
│   └── 07_01_para.log
├── 08_db_os
│   ├── 08_01_df.log
│   ├── 08_02_mount.log
│   └── 08_03_fstab.log
└── 09_db_log
    ├── 09_01_log.log
    └── 09_02_message.log

10 directories, 67 files
[root@testos ~]# 
~~~

#### 移动log文件到指定路径

~~~shell
#创建存放log的文件夹
mkdir -p /tmp/log
#移动所有的log文件到指定的目录
find /home/oracle/dbcheck/log -name "*.log" -exec mv {} /tmp/log \;
~~~

### 使用Python生成word报告

#### 升级Python版本到3.X

~~~shell
mkdir anaconda
cd anaconda/
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh
rm -f /usr/bin/python
ln -s /root/anaconda3/bin/python /usr/bin/python
python -V
pip -V
pip install python-docx
~~~



#### 执行脚本生成word报告

~~~shell
#根据情况修改py脚本中的log文件路径，然后执行py脚本
python 10.0.0.11_3.9_0620.py
~~~



