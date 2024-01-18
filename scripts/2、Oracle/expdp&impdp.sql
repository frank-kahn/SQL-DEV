-- 数据泵导出排除系统schema
exclude=schema:"in('SYS','SYSTEM','xxx','xxxx','xxxxx')"



-- 数据校验对比脚本
select 'select count(1) from '||owner||'.'||segment_name||';'
 from dba_segments,dba_users
 where segment_type='TABLE'
       and owner = username
       and default_tablespace not in ('SYSTEM','SYSAUX');


-- expdp到时的时候，并行写怎么配置最优
directory=exp_dir
dumpfile=for_union_query.dmp
logfile=for_union_query.log
CLUSTER=N
include=table:"in(select table_name from tables_tobe_exported where owner='es')"
parallel=10
schemas=ES
compression=all

为了防止数据错乱,Oracle不允许多个进程对同一个dmp文件进行同时写入，而某个进程如果长时间无法获取dmp文件的写权限，就会报ORA-39095错误
-- 要加快导出速度，需要几方面来配合:
数据库写进程
并行数
导出文件个数

https://www.cnblogs.com/halberd-lee/p/11052422.html