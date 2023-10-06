https://www.modb.pro/video/7453
PostgreSQL DBA one day

PostgreSQL中的锁 - 张树杰
https://www.modb.pro/video/5128

PostgreSQL日常工作分享
https://www.modb.pro/video/3668

PostgreSQL深入学习与运维管理方法论
https://www.modb.pro/video/3206


PostgreSQL疑难案例分享
https://www.modb.pro/video/3202


--针对表设置指定参数
alter table test set (autovacuum_vacuum_scale_factor=0.1);


-- 查看阻塞的pid
select pg_blocking_pids(pid),pid,query from pg_stat_activity;


--插件存放路径
--1、sql文件和control文件
$PGHOME/share/postgresql/extension
--2、so文件
$PGHOME/lib/postgresql


-- 查看主备复制情况
select * from pg_stat_replication;


--获取lsn位点对于的日志文件
select * from pg_walfile_name(pg_current_wal_lsn());
select * from pg_walfile_name('0/15548E8');

-- 查询函数信息
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'fresh';

-- 获取当前事务日志的写入位置（LSN）
select pg_current_wal_lsn();
-- 获取当前事务日志的写入位置，并转换成对应的文件命名格式
select * from pg_walfile_name('0/163B538');
-- 查看表物理存放位置
select pg_relation_filepath('employees');



-- 获取复制槽的确认位置和延迟大小
SELECT slot_name, active, pg_current_wal_lsn() - restart_lsn AS replication_lag
FROM pg_replication_slots;

-- 假设 WAL 日志大小为 16 MB
WITH replication_lag_mb AS (
  SELECT slot_name, active, (pg_current_wal_lsn() - restart_lsn) / (1024 * 1024 * 16) AS replication_lag_mb
  FROM pg_replication_slots
)
SELECT slot_name, active, replication_lag_mb,
       replication_lag_mb * 16 AS data_size_in_mb
FROM replication_lag_mb;





--权限管理
https://blog.csdn.net/eagle89/article/details/112169903
https://www.cnblogs.com/xiaotengyi/p/10132083.html
https://blog.csdn.net/suoyue_py/article/details/121159908

--运维文档
https://blog.csdn.net/qq_33445829/article/details/126636295?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522166347961116800184174899%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=166347961116800184174899&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-1-126636295-null-null.142^v47^control_1,201^v3^control_1&utm_term=%E3%80%90postgressql%E6%95%B0%E6%8D%AE%E5%BA%93%E8%BF%90%E7%BB%B4%E6%96%87%E6%A1%A3%E3%80%91&spm=1018.2226.3001.4187


--火焰图
https://www.modb.pro/db/49039


--锁
https://blog.csdn.net/u012551524/article/details/124195235


-- 怎么样一次查出某个用户下对象的依赖关系影响

https://pgfans.cn/q/805

WITH RECURSIVE x AS
(
 SELECT member::regrole,
     roleid::regrole AS role,
     member::regrole || ' -> ' || roleid::regrole AS path
 FROM pg_auth_members AS m
 WHERE roleid > 16384
 UNION ALL
 SELECT x.member::regrole,
     m.roleid::regrole,
     x.path || ' -> ' || m.roleid::regrole
 FROM pg_auth_members AS m
  JOIN x ON m.member = x.role
 )
 SELECT member, role, path
 FROM x
 ORDER BY member::text, role::text;

关于PG里的VACUUM
https://pgfans.cn/a/2093
 
 






-- 修改用户密码
alter user postgres with encrypted password 'postgres';






--离线安装postgresql数据库
https://blog.51cto.com/u_15162069/2779522


--Postgresql 如何清理WAL日志
https://www.jb51.net/article/203835.htm




postgresql ha patroni
https://blog.csdn.net/ctypyb2002/category_8091948.html




问题1；
pg_ident.conf 文件配置失败，操作系统用户，映射数据库用户，配置好后不起作用
问题2：
表空间下有数据，如何删除，如何安全的删除，如何确定表空间下有哪些数据，数据库或者对象
问题3：
如何清理wal日志，怎么操作最安全，不会丢失数据
问题4：
有自定义表空间的时候，pg_basebackup怎么备份




 
 
dvdrental=# select chr(36731)|| chr(33311)|| chr(24050)|| chr(36807)|| chr(19975)|| chr(37325)|| chr(23665);
    ?column?    
----------------
 轻舟已过万重山
(1 row) 


#PostgreSQL行格式解析： hexdump -C 数据文件 
1 如果存储NULL,不占用空间; 
2 如果存储不为NULL，varchar只占用实际长度的空间,char则用空格填充剩余空间; 
3 行开头按8字节对齐; 
4 插入的第一行数据在数据页的底部, 
5 更新或删除数据行时,原数据行仍在,t_xmax指示更新或删除的事务ID 
6 t_infomask 0 x0001 指示是否有空字段 
7 行头不存储字段长,而是让字段间有一个字节的间隔



public模式下有大表，owner为root 如果规范化操作，建立业务schema，
业务用户，数据如何迁移过去 数据量在10亿左右 同库逻辑复制能否实现？
pg_dump如何实现？
