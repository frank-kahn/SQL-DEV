--查看PDB信息（在CDB模式下）

-- 为pdb创建单独的tns
select pdb,name from v$services;
-- 使用查询的 name 设置tnsnames.ora
sqlplus sys/oracle@pdb1 as sysdba

show pdbs   --查看所有pdb
select name,open_mode from v$pdbs;  --v$pdbs为PDB信息视图
select con_id, dbid, guid, name , open_mode from v$pdbs;
--切换容器

alter session set container=orcl1   --切换到PDBorcl1容器
alter session set container=CDB$ROOT    --切换到CDB容器
--查看当前属于哪个容器

select sys_context('USERENV','CON_NAME') from dual; --使用sys_context查看属于哪个容器
show con_name   --用show查看当前属于哪个容器
--启动PDB

alter pluggable database orcl1 open;    --开启指定PDB
alter pluggable database all open;  --开启所有PDB
alter session set container=orcl1;  --切换到PDB进去开启数据库
startup
--关闭PDB

alter pluggable database orcl1 close;       --关闭指定的PDB
alter pluggable database all close;     --关闭所有PDB
alter session set container=orcl1;  --切换到PDB进去关闭数据库
shutdown immediate
--创建或克隆前要指定文件映射的位置（需要CBD下sysdba权限）

alter system set db_create_file_dest='/u01/app/oracle/oradata/orcl/orcl2';
--创建一个新的PDB：（需要CBD下sysdba权限）

create pluggable database test admin user admin identified by admin;    
alter pluggable database test_pdb open;    --将test_pdb 打开
--克隆PDB（需要CBD下sysdba权限）

create pluggable database orcl2 from orcl1;   --test_pdb必须是打开的，才可以被打开
alter pluggable database orcl2 open;   --然后打开这个pdb
--删除PDB（需要CBD下sysdba权限）

alter pluggable database  orcl2 close;  --关闭之后才能删除
drop pluggable database orcl2 including datafiles;  --删除PDB orcl2
--设置CDB启动PDB自动启动（在这里使用的是触发器）

CREATE OR REPLACE TRIGGER open_pdbs
AFTER STARTUP ON DATABASE
BEGIN
EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ALL OPEN';
END open_pdbs;
/