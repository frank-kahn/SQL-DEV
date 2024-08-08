-- 主机准备
#定义主机序号变量
host_num=101
#修改主机名
hostnamectl set-hostname fgedudb${host_num}
#修改hosts文件
sed -i "s/192.168.1.51/192.168.1.${host_num}/" /etc/hosts
sed -i "s/fgedudb51/fgedudb${host_num}/" /etc/hosts
#修改IP配置文件信息
sed -i "s/192.168.1.51/192.168.1.${host_num}/" /etc/NetworkManager/system-connections/ens160.nmconnection
sed -i '/^uuid/d' /etc/NetworkManager/system-connections/ens160.nmconnection
#重启主机
reboot
#检查相关配置
grep fgedu /etc/hosts
egrep "^address|^uuid" /etc/NetworkManager/system-connections/ens160.nmconnection
hostname




-- 初始化环境
pg_ctl stop
rm -rf /postgresql/data/*
rm -rf /postgresql/log/*
rm -rf /postgresql/arch/*
pg_basebackup -h 192.168.1.51 -p 5432 -U repuser -W -X stream -F p -P -R -D /postgresql/data -l backup20240728
pg_ctl start

*/

-- 创建测试数据
initdb -D /postgresql/data -E UTF8 --lc-collate=C --lc-ctype=en_US.utf8 -U postgres
psql -c "create user fgedu with password 'fgedu123' nocreatedb;"
psql -c "create database fgedudb with owner=fgedu template=template0 encoding='UTF8' lc_collate='C' lc_ctype='en_US.UTF8' connection limit = -1;"
psql -c "alter user postgres with password 'rootroot';"
psql -d fgedudb -U fgedu -f /postgresql/soft/fgedudb.sql


-- 远程查询
export PGPASSWORD=fgedu123
psql -h 192.168.1.51 -U fgedu02 -d fgedudb02 -c ""

export PGPASSWORD=rootroot
psql -U postgres -c "select pg_switch_wal();"
psql -h 192.168.1.51 -U postgres -c "select pg_switch_wal();"

export PGPASSWORD=rootroot
psql -h 192.168.1.100 -U postgres -c "select * from delay_check;"
































求一份mysql dba运维脚本，类似oracle dba 使用 ora脚本或者 percona-toolkit 工具查看主从延时，kill等功能
https://www.modb.pro/issue/34884


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
https://cloud.tencent.com/developer/article/1669853

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
'



-- 如何正确在windows server core（无图形界面）安装Oracle 19c 
www.modb.pro/db/1740748717920694272
-- 《pg_profile安装和配置_含pg_stat_kcache插件》
www.modb.pro/db/1737005135493160960

-- 《数据库备份脚本（Oracle/MySQL/PG/openGauss》
www.modb.pro/db/1746456741822943232

-- 《记一次MySQL生产环境CPU与内存双爆（都100%）的排查过程》
www.modb.pro/db/1748277093398040576
3、《PG高可用之repmgr篇》www.modb.pro/doc/124414

1、《运维5年OGG经典错误及处理方式集合》www.modb.pro/db/1751738048563990528
2、《日常巡检SQL会引起PG实例crash ？含故障处理》www.modb.pro/db/1751838751907205120
3、《价值3K的Percona XtraBackup全备与增量备份脚本》www.modb.pro/db/1752188769272942592

1、《小白也能学会的Oracle优化教程-主打零基础》www.modb.pro/db/1755563387710951424
2、《Oracle数据库常规维护手册.pdf》https://www.modb.pro/doc/125247

1、《如何优化一个看似正常的数据库》www.modb.pro/db/1760112323750612992
2、《Oracle数据库应急方案(二).doc》www.modb.pro/doc/125419
3、《MySQL8.0如何分析TOP SQL》www.modb.pro/db/1760587202291650560

1、《Oracle表空间和数据文件遇到的坑》www.modb.pro/db/1763125793060884480
2、《PostgreSQL安全修葺》www.modb.pro/db/1765183724995579904
3、《Oracle深度巡检工作指导书.docx》www.modb.pro/doc/126032

1、《Oracle 高可用性（RAC）技术解决方案及实现过程.docx》www.modb.pro/doc/126448
2、《Postgre+pgpool实现HA.docx》www.modb.pro/doc/125639
3、《数据库设计(MySQL)避坑指南》www.modb.pro/db/1762011570709229568

1、《Oracle数据库常规巡检项目和命令.docx》www.modb.pro/doc/126659
2、《MySQL导入N种实现方式》www.modb.pro/db/1765214556288290816
3、《pgbouncer的这些坑，你踩过几个？》www.modb.pro/db/1770267158911717376

《ogg基础学习.docx》www.modb.pro/doc/128416
1、《Oracle经典的SQL语句训练(100例).doc》www.modb.pro/doc/128260
2、《MySQL DBA 日常运维常用命令总结》www.modb.pro/db/1785176462622003200

1、《Oracle数据库常用运维SQL语句.docx》www.modb.pro/doc/129598
2、《MySQL参数配置详解.pdf》www.modb.pro/doc/129383

1、《linux7安装oracle19c-rac.docx》www.modb.pro/doc/130202
2、《使用xtrabackup备份工具完全恢复MySQL数据库》www.modb.pro/db/1791643273223294976
3、《PostgreSQL数据库常用SQL》www.modb.pro/db/1790042714368708608

1、《2023年中国数据库年度行业分析报告.pdf》-20万字梳理数据库行业发展现状和技术要点 www.modb.pro/doc/130680?sq
2、《MySQL 半同步机制解读》www.modb.pro/db/1793471763187306496
3、《Oracle高水位线操作相关.sql》 www.modb.pro/doc/130314

【💻技术干货】
1、《Oracle数据库的安全配置指南.pdf》www.modb.pro/doc/130933
2、《MySQL 8.0 MGR、InnoDB 集群搭建及 MySQL Shell、Router 的使用.docx》www.modb.pro/doc/130659