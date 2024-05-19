求一份mysql dba运维脚本，类似oracle dba 使用 ora脚本或者 percona-toolkit 工具查看主从延时，kill等功能
https://www.modb.pro/issue/34884


在Oracle中，coe_load_sql_profile.sql脚本的作用是什么？
https://cloud.tencent.com/developer/article/1515898


关于 utlirplscope.sql 脚本
https://www.oracle.com/technetwork/database/utlirplscope-087912-zhs.html






Linux如何用脚本监控Oracle发送警告日志ORA-报错发送邮件
https://www.cnblogs.com/PiscesCanon/p/13281926.html








-- 大神的博客
https://github.com/ChenHuajun
https://chenhuajun.github.io

-- MySQL配置SSL加密连接
https://blog.csdn.net/qq_39572257/article/details/116227265

-- 巡检脚本
https://github.com/dbbao/dbhealthcheck

#云下数据库导出导入到云上并重名
#1、导出
#如下testdb为数据库名，如下方式导出不带创建数据库的命令
mysqldump -uroot -proot testdb > testdb.sql

-- 模板
download.csdn.net/download/xx/xxx
blog.csdn.net/xxx/article/details/xxx
www.cnblogs.com/xxx/p/xxx.html
www.cnblogs.com/xxx/archive/2010/06/24/1764067.html
blog.51cto.com/xxx/xxx
blog.itpub.net/xxx/viewspace-xxxx
zhuanlan.zhihu.com/p/xxx
docs.oracle.com/en/database/oracle/oracle-database/12.2/admin/creating-and-removing-pdbs-with-sql-plus.html
www.modb.pro/db/14344
stackoverflow.com/questions/xxx/xxx

-- Oracle
RAC巡检
  1、rac各个进程的含义
  2、asm磁盘组日常维护和相关的系统视图
  3、ocr管理：备份恢复
  4、rac日常维护
  
Dataguard：
  1、熟悉搭建
  2、熟悉巡检  
备份恢复：
  1、rman备份恢复
  2、expdp备份恢复（字符集问题、标准的流程、表空间、用户、概要文件问题）
常用包、系统表、动态性能视图
userenv函数使用案例
等待事件



-- PG
全备+增量的异机恢复
表膨胀深入学习
事务回卷
性能优化


-- MySQL调优实践系列课程
主从搭建与修复
性能优化


-- Oracle rowid详解
https://blog.csdn.net/Flychuer/article/details/120759295/
https://blog.csdn.net/weixin_33845477/article/details/92647429
https://blog.51cto.com/19880614/1332195
https://www.cnblogs.com/xzdblogs/p/6495755.html




-- MySQL调优实践系列课程
https://edu.51cto.com/course/34235.html

-- Mysql进阶篇（二）之索引
https://zhuanlan.zhihu.com/p/643924600?utm_id=0



-- Oracle待学习
rac下各个日志的路径
rman target / debug trace=rman_debug.log
熟悉Oracle各个进程的作用，前后台进程


-- Oracle数据库日常巡检方法
https://edu.51cto.com/video/535.html

rem 面试题目
https://www.modb.pro/db/134451



-- 强制日志各个字段说明
SELECT  LOG_MODE,FORCE_LOGGING,SUPPLEMENTAL_LOG_DATA_MIN  FROM  V$DATABASE;








-- Oracle数据文件迁移（详细版）
https://blog.csdn.net/jiejie5945/article/details/8314710

-- MySQL数据库DBA 防坑指南
https://blog.csdn.net/andrew1024/article/details/129656781

-- 一个踩坑记录：在安全更新模式下进行数据的修改与删除
https://blog.csdn.net/weixin_45370422/article/details/118121235


-- MySql中安全模式sql_safe_updates
https://blog.csdn.net/qq_37778018/article/details/96907132


-- Mysql 删除列遇到的小坑
https://blog.csdn.net/qq_43285863/article/details/119235199


-- 全网唯一解决Mysql数据库宕机生产事故的通用方法高级DBA真实案例解答
https://blog.csdn.net/nasen512/article/details/130705957


-- MySQL大无语事件：一次生产环境的死锁事故，看看我怎么排查
https://blog.csdn.net/m0_63437643/article/details/128577158


-- 一次MySQL分页导致的线上事故
https://itsoku.blog.csdn.net/article/details/134389619


-- 记录一次生产环境MySQL突然变慢事故
https://blog.csdn.net/qq_37352374/article/details/110425223


-- 一次MySQL数据库生产事故以及问题定位
https://blog.csdn.net/Godlike_M/article/details/107973009


-- Mysql REGEXP生产事故
https://blog.csdn.net/qq_45563131/article/details/123016324


-- MySql表的主键超限导致的生产事故
https://blog.csdn.net/yudian1991/article/details/127255898



-- Mysql常见故障及解决方案
https://blog.csdn.net/mqb195128/article/details/126683828


-- Oracle分区表及索引迁移表空间
https://blog.csdn.net/peixiaokai/article/details/116306744

-- oracle表空间数据迁移另一个表空间,oracle的数据表、索引从一个表空间迁移到另一个表空间...
https://blog.csdn.net/weixin_31460419/article/details/116337634



-- Oracle传输表空间迁移数据库
https://blog.51cto.com/koumm/1574822

-- ORACLE RAC集群 大数据文件表空间迁移至新磁盘组

https://blog.51cto.com/u_3557740/4865008


-- 了解如何在 Oracle Data Guard 中迁移
https://docs.oracle.com/zh-cn/solutions/reduce-database-migration-downtime/learn-migrating-oracle-data-guard1.html#GUID-8B30D377-A477-4D63-97C1-46DEC64ACA0D


expdp \'sys/oracle as sysdba\' directory=dmp dumpfile=tablespace_name.dmp logfile=tablespace_name.log transport_tablespaces=tablespace_name
convert tablespace test_tb to platform 'Microsoft Windows IA (64-bit)' format '/oradata/backup/%U';
