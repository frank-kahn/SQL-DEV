--------------------------------------wal日志-------------------------------------------
-- 获取 WAL 文件的数量，需要pg_monitor角色权限才能查询
SELECT COUNT (*) FROM pg_ls_waldir();
-- 检查未归档文件的数量
SELECT count (*) AS count FROM pg_ls_dir('pg_wal/archive_status')
WHERE pg_ls_dir ~ E'^[0-9A-F]{24}\.ready$';


----------------------------------------发布端-----------------------------------------
-- 创建一个发布，发布两个表中所有更改：
CREATE PUBLICATION mypublication FOR TABLE users, departments;
-- 创建一个发布，发布所有表中的所有更改：
CREATE PUBLICATION alltables FOR ALL TABLES;
-- 创建一个发布，只发布一个表中的INSERT操作：
CREATE PUBLICATION insert_only FOR TABLE mydata  WITH (publish = 'insert');
-- 将发布修改为只发布删除和更新： 
ALTER PUBLICATION noinsert SET (publish = 'update, delete');
-- 给发布添加一些表：
ALTER PUBLICATION mypublication ADD TABLE users01, departments01;
-- 删除发布
drop pubilcation pub1;
-- 查看发布
select * from pg_publication;
-- 发布哪些表
select * from pg_publication_tables;
-- 所有的订阅者
select * from pg_stat_replication;


----------------------------------------订阅端-----------------------------------------
-- 查看订阅
select * from pg_sublication;
-- 将订阅的发布更改为insert_only
ALTER SUBSCRIPTION mysub SET PUBLICATION insert_only;
-- 禁用（停止）订阅：
ALTER SUBSCRIPTION mysub DISABLE;
-- 刷新订阅
alter subscription pub1 refresh publication;
-- 复制进度
select * from pg_stat_subscription;
-- 订阅哪些表
select *,srrelid::regclass from pg_subscription_rel;
-- 删除订阅
drop subscription pub1;


----------------------------------------复制槽-----------------------------------------
select * from pg_replication_slots;

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

-- 复制延迟
select database,
       slot_type,
       slot_name,
       pg_size_pretty(replication_lag_bytes) as lag_size,
       active,
       active_pid
from (select pg_wal_lsn_diff(pg_current_wal_lsn() - restart_lsn) as replication_lag_bytes,
             slot_name,
             slot_type,
             database,
             active,
             active_pid
        from pg_replication_slots) as t;




-- 设置表的发布订阅详细程度
alter table test_t replica identity full;
-- 设置的属性信息查询以下系统表字段
pg_class.relreplident