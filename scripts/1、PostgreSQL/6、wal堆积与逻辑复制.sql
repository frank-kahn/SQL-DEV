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