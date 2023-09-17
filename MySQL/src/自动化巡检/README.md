# MySQL自动巡检使用说明

## 脚本目录结构

~~~shell
[root@centos7 ~]# tree -f /root/shell/
/root/shell
|-- /root/shell/01_db_info
|   |-- /root/shell/01_db_info/01_01_os.sh
|   |-- /root/shell/01_db_info/01_02_time.sh
|   |-- /root/shell/01_db_info/01_03_ver.sh
|   |-- /root/shell/01_db_info/01_04_db.sh
|   |-- /root/shell/01_db_info/01_05_dbctime.sh
|   |-- /root/shell/01_db_info/01_06_runtime.sh
|   |-- /root/shell/01_db_info/01_07_char.sh
|   |-- /root/shell/01_db_info/01_08_char.sh
|   |-- /root/shell/01_db_info/01_09_port.sh
|   `-- /root/shell/01_db_info/01.sh
|-- /root/shell/02_db_file
|   |-- /root/shell/02_db_file/02_01_tab.sh
|   |-- /root/shell/02_db_file/02_02_undo.sh
|   |-- /root/shell/02_db_file/02_03_temp.sh
|   |-- /root/shell/02_db_file/02_04_redo.sh
|   |-- /root/shell/02_db_file/02_05_redosize.sh
|   |-- /root/shell/02_db_file/02_06_redogroup.sh
|   |-- /root/shell/02_db_file/02_07_redodir.sh
|   |-- /root/shell/02_db_file/02_08_redotrx.sh
|   |-- /root/shell/02_db_file/02_09_binlog.sh
|   |-- /root/shell/02_db_file/02_10_binlogdir.sh
|   |-- /root/shell/02_db_file/02_11_binloglist.sh
|   |-- /root/shell/02_db_file/02_12_binlogstatus.sh
|   |-- /root/shell/02_db_file/02_13_binformat.sh
|   |-- /root/shell/02_db_file/02_14_bincache.sh
|   |-- /root/shell/02_db_file/02_15_binuse.sh
|   |-- /root/shell/02_db_file/02_16_binexp.sh
|   |-- /root/shell/02_db_file/02_17_binsize.sh
|   |-- /root/shell/02_db_file/02_18_realy.sh
|   |-- /root/shell/02_db_file/02_19_realyfile.sh
|   |-- /root/shell/02_db_file/02_20_realy.sh
|   |-- /root/shell/02_db_file/02_21_config.sh
|   |-- /root/shell/02_db_file/02_22_pid.sh
|   |-- /root/shell/02_db_file/02_23_socket.sh
|   `-- /root/shell/02_db_file/02.sh
|-- /root/shell/03_db_master
|   |-- /root/shell/03_db_master/03_01_slave_io.sh
|   |-- /root/shell/03_db_master/03_02_slave_sql.sh
|   |-- /root/shell/03_db_master/03_03_behind.sh
|   |-- /root/shell/03_db_master/03_04_semi.sh
|   `-- /root/shell/03_db_master/03.sh
|-- /root/shell/04_db_object
|   |-- /root/shell/04_db_object/04_01_user.sh
|   |-- /root/shell/04_db_object/04_02_tablemb.sh
|   |-- /root/shell/04_db_object/04_03_indexmb.sh
|   |-- /root/shell/04_db_object/04_04_creuser.sh
|   |-- /root/shell/04_db_object/04_05_tab.sh
|   |-- /root/shell/04_db_object/04_06_view.sh
|   |-- /root/shell/04_db_object/04_07_trigger.sh
|   |-- /root/shell/04_db_object/04_08_proc.sh
|   |-- /root/shell/04_db_object/04_09_part.sh
|   |-- /root/shell/04_db_object/04_10_engine.sh
|   `-- /root/shell/04_db_object/04.sh
|-- /root/shell/05_db_bakchk
|   |-- /root/shell/05_db_bakchk/05_01_cron.sh
|   |-- /root/shell/05_db_bakchk/05_02_baksize.sh
|   |-- /root/shell/05_db_bakchk/05_03_bakcheck.sh
|   `-- /root/shell/05_db_bakchk/05.sh
|-- /root/shell/06_db_per
|   |-- /root/shell/06_db_per/06_01_process.sh
|   |-- /root/shell/06_db_per/06_02_conn.sh
|   |-- /root/shell/06_db_per/06_03_wait.sh
|   |-- /root/shell/06_db_per/06_04_trx.sh
|   |-- /root/shell/06_db_per/06_05_slow.sh
|   |-- /root/shell/06_db_per/06_06_mem.sh
|   |-- /root/shell/06_db_per/06_07_mem.sh
|   |-- /root/shell/06_db_per/06_08_cpu.sh
|   `-- /root/shell/06_db_per/06.sh
|-- /root/shell/07_db_para
|   |-- /root/shell/07_db_para/07_01_para.sh
|   |-- /root/shell/07_db_para/07_02_value.sh
|   `-- /root/shell/07_db_para/07.sh
|-- /root/shell/08_db_os
|   |-- /root/shell/08_db_os/08_01_dfh.sh
|   |-- /root/shell/08_db_os/08_02_dfi.sh
|   |-- /root/shell/08_db_os/08_03_mount.sh
|   |-- /root/shell/08_db_os/08_04_fstab.sh
|   `-- /root/shell/08_db_os/08.sh
`-- /root/shell/09_db_log
    |-- /root/shell/09_db_log/09_01_err.sh
    |-- /root/shell/09_db_log/09_02_message.sh
    `-- /root/shell/09_db_log/09.sh

9 directories, 74 files
[root@centos7 ~]# 
~~~



## 脚本说明

### 文件夹说明

| 脚本文件夹名 | 说明             | 详细说明                                                     |
| ------------ | ---------------- | ------------------------------------------------------------ |
| 01_db_info   | 数据库基础信息   | 操作系统版本、巡检开始时间、数据库版本、数据库名称、数据库创建时间、数据库运行时间、数据库字符集、实例字符集、端口号。 |
| 02_db_file   | 数据库文件信息   | 表空间数量统计、UNDO表空间信息、临时表空间信息、Redo写缓存、Redo log file大小、Redo  log目录位置、trx_commit、Binlog是否启用、Binlog路径信息、Binlog文件列表、Binlog  Position信息、Binlog格式、Binlog缓存、Binlog缓存使用情况、Binlog保留时间、Realy log路径、Realy  log文件名称、Realy存储方式、参数文件、pid文件、socket文件。 |
| 03_db_master | 数据库高可用信息 | I/O线程状态、SQL线程状态、同步延时、同步方式等。             |
| 04_db_object | 数据库对象信息   | 用户信息、数据库总大小、索引大小、用户创建时间、用户表数量、用户视图数量、用户触发器数量、用户存储过程数量、用户分区表数量、用户存储引擎数量。 |
| 05_db_bakchk | 数据库备份信息   | 数据库本地备份计划任务、数据库备份文件大小、数据库备份错误信息。 |
| 06_db_per    | 数据库性能信息   | process信息、最大连接信息、等待事件信息、事务信息、慢日志信息、内存使用率、内存使用top 10进程、CPU使用top  10进程。 |
| 07_db_para   | 数据库参数信息   | 数据库参数                                                   |
| 08_db_os     | 数据库系统信息   | 磁盘空间使用率、磁盘inode使用率、mount挂载信息、fstab开机自动挂载信息。 |
| 09_db_log    | 数据库日志信息   | mysql error日志、操作系统message日志。                       |

### 脚本说明

| 脚本名称              | 说明                                  |
| --------------------- | ------------------------------------- |
| 01.sh                 |                                       |
| 01_01_os.sh           | 查看操作系统版本                      |
| 01_02_time.sh         | 获取当前时间                          |
| 01_03_ver.sh          | 查看数据库版本                        |
| 01_04_db.sh           | 查看业务数据信息                      |
| 01_05_dbctime.sh      | 实例创建时间                          |
| 01_06_runtime.sh      | 数据库运行时间                        |
| 01_07_char.sh         | 数据库字符集                          |
| 01_08_char.sh         | 实例字符集信息                        |
| 01_09_port.sh         | 数据库端口                            |
| 02.sh                 |                                       |
| 02_01_tab.sh          | 表空间信息                            |
| 02_02_undo.sh         | undo信息                              |
| 02_03_temp.sh         | temp信息                              |
| 02_04_redo.sh         | innodb_log_buffer_size                |
| 02_05_redosize.sh     | innodb_log_file_size                  |
| 02_06_redogroup.sh    | redo组数量                            |
| 02_07_redodir.sh      | redo目录                              |
| 02_08_redotrx.sh      | innodb_flush_log_at_trx_commit        |
| 02_09_binlog.sh       | log_bin                               |
| 02_10_binlogdir.sh    | log_bin_basename                      |
| 02_11_binloglist.sh   | Show binary logs;                     |
| 02_12_binlogstatus.sh | Show master status\G;                 |
| 02_13_binformat.sh    | binlog_format                         |
| 02_14_bincache.sh     | binlog_cache_size                     |
| 02_15_binuse.sh       | Show variables like '%binlog_cache%'; |
| 02_16_binexp.sh       | expire_logs_days                      |
| 02_17_binsize.sh      | Max_binlog_size                       |
| 02_18_realy.sh        | relay_log_basename                    |
| 02_19_realyfile.sh    | relay_log_info_file                   |
| 02_20_realy.sh        | relay_log_info_repository             |
| 02_21_config.sh       | 获取my.cnf路径                        |
| 02_22_pid.sh          | pid_file                              |
| 02_23_socket.sh       | socket                                |
| 03.sh                 |                                       |
| 03_01_slave_io.sh     | I/O线程状态                           |
| 03_02_slave_sql.sh    | SQL线程状态                           |
| 03_03_behind.sh       | 主从同步延时情况                      |
| 03_04_semi.sh         | 同步方式                              |
| 04.sh                 |                                       |
| 04_01_user.sh         | 用户信息                              |
| 04_02_tablemb.sh      | 表大小                                |
| 04_03_indexmb.sh      | 索引大小                              |
| 04_04_creuser.sh      | 用户创建时间                          |
| 04_05_tab.sh          | 表数量                                |
| 04_06_view.sh         | 视图数量                              |
| 04_07_trigger.sh      | 触发器数量                            |
| 04_08_proc.sh         | 存储过程数量                          |
| 04_09_part.sh         | 分区表数量                            |
| 04_10_engine.sh       | 存储引擎数量                          |
| 05.sh                 |                                       |
| 05_01_cron.sh         | 备份计划任务                          |
| 05_02_baksize.sh      | 备份大小                              |
| 05_03_bakcheck.sh     | 备份日志                              |
| 06.sh                 |                                       |
| 06_01_process.sh      | 查询数据进程信息                      |
| 06_02_conn.sh         | 最大连接信息                          |
| 06_03_wait.sh         | 等待事件信息                          |
| 06_04_trx.sh          | 事务信息                              |
| 06_05_slow.sh         | 慢日志信息                            |
| 06_06_mem.sh          | 内存使用率信息                        |
| 06_07_mem.sh          | 占用内存                              |
| 06_08_cpu.sh          | CPU top 10                            |
| 07.sh                 |                                       |
| 07_01_para.sh         | 参数名                                |
| 07_02_value.sh        | 参数值                                |
| 08.sh                 |                                       |
| 08_01_dfh.sh          | 磁盘空间                              |
| 08_02_dfi.sh          | iNode空间                             |
| 08_03_mount.sh        | mount信息                             |
| 08_04_fstab.sh        | 自动mount信息                         |
| 09.sh                 |                                       |
| 09_01_err.sh          | 错误日志信息                          |
| 09_02_message.sh      | 操作系统message信息                   |



## 配置巡检环境--待修改

~~~shell
su - oracle
mkdir -p /home/oracle/dbcheck/{scripts,log,tmp}
#上传脚本到scripts（并检查好权限）
chown -R oracle:oinstall /home/oracle/dbcheck
#创建存放log的空目录
mkdir -p /home/oracle/dbcheck/log/{00_db_input,01_db_info,02_db_file,03_db_rac,04_db_object,05_db_bakchk,06_db_per,07_db_para,08_db_os,09_db_log}
~~~

## 巡检步骤--待修改

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



