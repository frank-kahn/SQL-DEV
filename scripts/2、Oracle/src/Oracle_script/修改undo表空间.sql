--重建Oracle undo表空间文件，数据库状态静止时（无DML操作期间）执行UNDO表空间切换；
--已UNDOTBS2表空间举例，使用sqlplus登录到各节点执行。
--1、查询undo表空间信息：
select * from dba_tablespaces where contents = 'UNDO';
show parameter undo_;
--2、查询undo表空间数据文件及文件大小
select file_id, file_name, sum(bytes) / 1024 / 1024 "文件大小(MB)"
  from dba_data_files
 where tablespace_name in
       (select tablespace_name from dba_tablespaces where contents = 'UNDO')
 group by file_id, file_name;
--3、创建新undo表空间
create undo tablespace UNDOTBS2 datafile '+DATA/racdb/datafile/undotbs02.dbf' size 210M;
--4、设置新undo表空间为默认表空间
alter system set undo_tablespace = UNDOTBS2 scope=both;
--5、查询更改结果
select * from dba_tablespaces where contents = 'UNDO';
show parameter undo_;
--6、检查确认有问题的undo表空间中是否存在ONLINE的segment
select status,segment_name from dba_rollback_segs where status not in ('OFFLINE') and tablespace_name='UNDOTBS2';
--7、删除原先的undo表空间及文件
Drop tablespace UNDO_002 including contents and datafiles;
--8、关闭数据库
shutdown immediate
--9、启动数据库
startup
--10、为了保证启动的一致，重新生成pfile文件，在各个节点上执行
create pfile from spfile;
