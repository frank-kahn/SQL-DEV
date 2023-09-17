
su - oracle -c "cat <<eof> /soft/scripts/param.sql
alter system set max_dump_file_size='1024M' sid='*' scope=spfile;
alter system set control_file_record_keep_time=31;
alter system set deferred_segment_creation= FALSE sid='*' scope=spfile;
alter system set result_cache_max_size=0 sid='*' scope=spfile;
alter database datafile 1,2 resize 1g;
alter database datafile 1,2 autoextend off;
alter database datafile 3 resize 200M;
alter database datafile 3 autoextend off;
alter database tempfile 1 resize 1g;
alter database tempfile 1 autoextend off;

noaudit create session;
alter system set audit_sys_operations=false sid='*' scope=spfile;
alter system set audit_trail=none scope=spfile;
alter system set \"_cleanup_rollback_entries\"=10000 sid='*' scope=spfile;
alter system set db_files=2048 sid='*' scope=spfile;
exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(RETENTION=>21600,INTERVAL=>60);
alter system set event='28401 trace name context forever,level 1','10949 trace name context forever,level 1' sid='*' scope=spfile;

alter system set \"_optimizer_use_feedback\"=false sid ='*' scope=spfile;
alter system set \"_partition_large_extents\"=false scope=spfile sid='*';
alter system set \"_px_use_large_pool\"=true sid ='*' scope=spfile;
alter system set \"_use_adaptive_log_file_sync\"=FALSE sid='*' scope=spfile;
alter system set \"_optimizer_adaptive_cursor_sharing\"=false sid='*' scope=spfile;
alter system set \"_optimizer_extended_cursor_sharing\"=none sid='*' scope=spfile;
alter system set \"_optimizer_extended_cursor_sharing_rel\"=none sid='*' scope=spfile;
alter profile DEFAULT limit PASSWORD_LIFE_TIME UNLIMITED;
alter profile DEFAULT limit FAILED_LOGIN_ATTEMPTS unlimited;
alter profile DEFAULT limit PASSWORD_LOCK_TIME unlimited;
alter profile DEFAULT limit PASSWORD_GRACE_TIME unlimited;
select client_name,status from DBA_AUTOTASK_CLIENT;
exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name=>'auto optimizer stats collection',operation=> NULL,window_name=> NULL);
exec dbms_auto_task_admin.disable(client_name => 'sql tuning advisor',operation => NULL,window_name => NULL);
exec dbms_auto_task_admin.disable(client_name => 'auto space advisor',operation => NULL,window_name => NULL);
alter system set cell_offload_processing = FALSE sid='*' SCOPE=SPFILE;
alter system set inmemory_query = DISABLE sid='*' SCOPE=SPFILE;
alter system set \"_log_segment_dump_parameter\" = FALSE sid='*' scope=both;
alter system set \"_log_segment_dump_patch\" = FALSE sid='*' scope=both;
alter system set \"_b_tree_bitmap_plans\" = FALSE sid='*' SCOPE=SPFILE;
alter system set parallel_execution_message_size=32768 sid='*' scope=spfile;
alter system set \"_optimizer_null_aware_antijoin\"= FALSE sid='*' scope=spfile;
exec dbms_scheduler.disable('ORACLE_OCM.MGMT_CONFIG_JOB');
exec dbms_scheduler.disable('ORACLE_OCM.MGMT_STATS_CONFIG_JOB');
exit;
eof"

su - oracle -c "sqlplus -S / as sysdba @/soft/scripts/param.sql"

