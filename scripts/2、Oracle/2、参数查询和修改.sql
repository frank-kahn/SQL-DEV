set line 200
col name for a30
col value for a20
col isses_modifiable for a9
col ispdb_modifiable for a9
col isinstance_modifiable for a9
select name,value,isses_modifiable,issys_modifiable,ispdb_modifiable,isinstance_modifiable
from v$parameter
where regexp_like(name,'db_files','i');


_allow_resetlogs_corruption为true（目的是跳过使用resetlogs open数据库的一致性检查）




-- 隐藏参数查询（简单）
select a.ksppinm  parameter,
       a.ksppdesc description,
       b.ksppstvl session_value,
       c.ksppstvl instance_value
  from x$ksppi a, x$ksppcv b, x$ksppsv c
 where a.indx = b.indx
   and a.indx = c.indx
   and regexp_like(a.ksppinm,'omf','i')
 order by a.ksppinm;


-- 隐藏参数查询（详细）
select 
  name, 
  value, 
  decode(isdefault, 'TRUE', 'Y', 'N') as "Default", 
  decode(ISEM, 'TRUE', 'Y', 'N') as SesMod, 
  decode(ISYM, 'IMMEDIATE', 'I', 'DEFERRED','D', 'FALSE', 'N') as SysMod, 
  decode(IMOD, 'MODIFIED', 'U', 'SYS_MODIFIED','S', 'N') as Modified, 
  decode(IADJ, 'TRUE', 'Y', 'N') as Adjusted,
  description 
from 
  (  --GV\$SYSTEM_PARAMETER 
    select 
      x.inst_id as instance, 
      x.indx + 1, 
      ksppinm as name, 
      ksppity, 
      ksppstvl as value, 
      ksppstdf as isdefault, 
      decode(bitand(ksppiflg / 256, 1),1,'TRUE','FALSE') as ISEM, 
      decode(bitand(ksppiflg / 65536, 3),1,'IMMEDIATE',2,'DEFERRED','FALSE') as ISYM, 
      decode(bitand(ksppstvf, 7),1,'MODIFIED','FALSE') as IMOD, 
      decode(bitand(ksppstvf, 2),2,'TRUE','FALSE') as IADJ, 
      ksppdesc as description 
    from 
      x$ksppi x,x$ksppsv y 
    where 
      x.indx = y.indx 
      and substr(ksppinm, 1, 1) = '_' 
      and x.inst_id = USERENV('Instance') 
      AND (('$2' || 'null' <> 'null'and X.KSPPINM LIKE '%' || LOWER('$2')|| '%') 
           or ('$2' || 'null' = 'null' 
           and X.KSPPINM in (
            '_b_tree_bitmap_plane', '_disable_fast_validate', 
            '_fast_full_scan_enabled', '_gby_hash_aggregation_enabled', 
            '_gc_policy_time', '_gc_read_mostly_locking', 
            '_ktb_debug_flags', '_library_cache_advice', 
            '_like_with_bind_as_equality', 
            '_optimizer_extended_cursor_sharing', 
            '_optimizer_extended_cursor_sharing_rel', 
            '_optimizer_use_feedback', '_trace_files_public', 
            '_undo_autotune', '_use_adaptive_log_file_sync', 
            '_library_cache_advice', '_like_with_bind_as_equality')))
  ) 
order by name;