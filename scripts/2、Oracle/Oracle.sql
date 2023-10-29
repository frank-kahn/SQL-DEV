-- 如何查看 oracle 官方文档
https://blog.csdn.net/moveofgod/article/details/38688269

--Oracle一键安装脚本
https://github.com/DBAutoTask/OracleShellInstall 

运维,诊断,健康检查,优化定制工具ora
https://cloud.tencent.com/developer/article/2031508

https://www.bmc.com/blogs/top-dba-shell-scripts-for-monitoring-the-database/

ORACLE DBA应该掌握的9个免费工具
https://www.open-open.com/news/view/bf35ec


Oracle DBA的一天
https://www.modb.pro/db/403495
https://www.cnblogs.com/vmsysjack/p/12344902.html

-- 一篇不错的优化入门文档
https://www.cnblogs.com/Dreamer-1/p/6076440.html 


然后根据udump文件来查看。 
fast_start_mttr_target参数，实例恢复时间。


sqlplus sys/oracle@192.168.1.205:1521/lorcl19 as sysdba

Dataguard原理
RAC原理
文件系统 裸设备 ASM的区别
redo、undo的原理
文件丢失了怎么恢复
12c 19c的cdb pdb技术，内存怎么分配的原理
数据库慢怎么搞
PG数据库的相关理论

#VMware超详细Oracle RAC安装及搭建指南
https://blog.csdn.net/ldjjbzh626/article/details/103174891
#Linux 中安装Oracle GlodenGate详细教程
https://blog.csdn.net/qq_16566415/article/details/78295899







-- 完整的开启和关闭归档设置流程
-- 1、恢复区设置
show parameter db_recovery;
alter system set db_recovery_file_dest_size=10g scope=spfile sid='*';
alter system set db_recovery_file_dest='/archive';
-- 2、打开归档
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
-- 3、查看归档模式
archive log list
-- 4、关闭归档
shutdown immediate;
startup mount;
alter database noarchivelog;
alter database open;
-- 5、查看归档
select * from v$log;
select * from v$logfile;
select * from v$flash_recovery_area_usage;
report obsolete;
delete obsolete;
-- 6、备份归档
backup archivelog all;
也可以，先执行：
alter system switch logfile;
再找到归档日志位置，复制到别的地方即可。
rman target /
delete archivelog all completed before 'sysdate-7';
backup first
backup format '/tmp/arch-%t_%s_%u' archivelog all delete input; 或者
backup database plus archivelog;
-- 7、删除归档文件:
rman target / 或者 rman target user/password@tns list archivelog all;
crosscheck archivelog all; 
list expired archivelog all; 
delete expired archivelog all;






#如何在Oracle 19c expdp/impdp 脚本中不使用密码？
https://www.modb.pro/db/602204



-- 查看数据库中的表和列的字符集
SELECT table_name, column_name, data_type, data_length, char_length, data_precision, data_scale, character_set_name
FROM all_tab_columns
WHERE owner = 'schema_name';

