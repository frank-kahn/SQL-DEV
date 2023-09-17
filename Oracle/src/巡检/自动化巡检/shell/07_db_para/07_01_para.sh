#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
col owner for a40
col name for a30 
set lines 200 pages 1000
col pname for a35
col current_value for a10
col check_result for a12
set heading off
set feedback off
select distinct pname,current_value
  from (select nam.inst_id,
               nam.ksppinm pname,
               val.ksppstvl current_value,
               case
                 WHEN nam.ksppinm = 'max_dump_file_size' and
                      val.ksppstvl = '4096M' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'audit_trail' and val.ksppstvl = 'NONE' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'event' and
                      val.ksppstvl =
                      --- '10949 TRACE NAME CONTEXT FOREVER, LEVEL 1: 28401 TRACE NAME CONTEXT FOREVER, LEVEL 1' then
                      '28401 trace name context forever,level 1, 10949 trace name context forever,level 1' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'optimizer_dynamic_sampling' and
                      val.ksppstvl = '4' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'optimizer_index_cost_adj' and
                      val.ksppstvl = '40' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'deferred_segment_creation' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = '_optimizer_use_feedback' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = 'audit_sys_operations' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = '_use_adaptive_log_file_sync' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = '_undo_autotune' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = '_b_tree_bitmap_plans' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 WHEN nam.ksppinm = '_optimizer_mjc_enabled' and
                      val.ksppstvl = 'FALSE' then
                  'CORRECT'
                 else
                  'INCORRECT'
               end as check_result
          from x\$ksppi nam, x\$ksppsv val
         where nam.indx = val.indx
           and nam.ksppinm IN ('max_dump_file_size',
                               'audit_trail',
                               'event',
                               'optimizer_dynamic_sampling',
                               'optimizer_index_cost_adj',
                               'db_files',
                               'parallel_force_local',
                               '_optimizer_use_feedback',
                               '_partition_large_extents',
                               'deferred_segment_creation',
                               'audit_sys_operations',
                               '_optimizer_adaptive_cursor_sharing',
                               '_use_adaptive_log_file_sync',
                               '_undo_autotune',
                               '_b_tree_bitmap_plans',
                               '_optimizer_mjc_enabled')) para
 where CHECK_RESULT = 'INCORRECT'
 order by  PNAME;
exit;
EOF
