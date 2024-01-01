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
blog.51cto.com/xxx/xxx
blog.itpub.net/xxx/viewspace-xxxx
www.cnblogs.com/xxx/p/xxx.html
zhuanlan.zhihu.com/p/xxx



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

