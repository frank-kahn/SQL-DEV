-- 以只读模式打开数据库
alter database open read only;

-- 设置表空间只读/读写
alter tablespace ts01 read only;
alter tablespace ts01 read write;

-- 设置t1表只读/读写
alter table t1 read only;
alter table t1 read write;

