-- 数据泵导出排除系统schema
exclude=schema:"in('SYS','SYSTEM','xxx','xxxx','xxxxx')"



-- 数据校验对比脚本
select 'select count(1) from '||owner||'.'||segment_name||';'
 from dba_segments,dba_users
 where segment_type='TABLE'
       and owner = username
       and default_tablespace not in ('SYSTEM','SYSAUX');


