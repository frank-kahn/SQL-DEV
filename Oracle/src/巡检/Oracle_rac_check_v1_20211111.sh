#!/bin/sh
echo "########DB_VERSION############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
col COMP_ID for a30
col comp_name for a35
col version for a15
col status for a15
select COMP_ID,COMP_NAME,VERSION,STATUS from DBA_REGISTRY order by COMP_ID;
exit;
EOF
"

echo "########DB_CREATE_TIME############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
select dbid,name,to_char(created,'YYYY-MM-DD') created,log_mode from gv\\\$database;
exit;
EOF
"

echo "########DB_START_TIME############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
select version,instance_name,to_char(startup_time,'YYYY-MM-DD') startup_time,status from gv\\\$instance;
exit;
EOF
"

echo "########INSTANCE_STATUS############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
select instance_name,status from gv\\\$instance;
exit;
EOF
"

echo "########db_characterset############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
set pagesize 100
col PARAMETER for a20
col VALUE for a30
select PARAMETER,value from nls_database_parameters where parameter in ('NLS_CHARACTERSET');
exit;
EOF
"

echo "#######tablespace_status############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
col tablespace_name for a20
select tablespace_name,
       block_size,
       initial_extent,
       next_extent,
       max_size,
       status,
       contents,
       logging,
       extent_management,
       segment_space_management
  from dba_tablespaces;
exit;
EOF
"

echo "#######tablespace_use############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set pagesize 9999 
set linesize 132 
col tablespace_name for a35
select
a.tablespace_name,
a.Total_mb,
f.Free_mb,
round(a.total_MB-f.free_mb,2) Used_mb,
round((f.free_MB/a.total_MB)*100) \"Free\"
from
(select tablespace_name, sum(bytes/(1024*1024)) total_MB from dba_data_files group by tablespace_name) a,
(select tablespace_name, round(sum(bytes/(1024*1024))) free_MB from dba_free_space group by tablespace_name) f
WHERE a.tablespace_name = f.tablespace_name(+)
order by \"Free\";
exit;
EOF
"

echo "#######datafile_info############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 200
col tablespace_name for a20
col file_name for a65
select tablespace_name,
       file_name,
       file_id,
       status,
       trunc(bytes / 1024 / 1024 / 1024, 2) as FILE_GB,
       autoextensible,
       trunc(maxbytes / 1024 / 1024 / 1024, 2) as MAX_GB
  from dba_data_files
 order by file_id;
exit;
EOF
"

echo "#######UNDO_info############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
select t.status,sum(t.blocks)*8/1024||'M' size_M
from dba_undo_extents t
group by t.status;
exit;
EOF
"

echo "#######rollname############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 200
select * from v\\\$rollname;
exit;
EOF
"

echo "#######rollname2############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 150
col tablespace_name for a10
set pagesize 100
select owner, tablespace_name, segment_id, segment_name, status
  from dba_rollback_segs order by 2,3;
exit;
EOF
"

echo "#######tempfile_info############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
col tablespace_name for a20
col file_name for a40
select tablespace_name,
       file_name,
       file_id,
       status,
       trunc(bytes / 1024 / 1024 / 1024, 2) as FILE_GB,
       autoextensible,
       trunc(maxbytes / 1024 / 1024 / 1024, 2) as MAX_GB
  from dba_temp_files
 order by file_id;
exit;
EOF
"

echo "#######temp_use############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
SET PAGESIZE 400
SET LINES 300
COL D.TABLESPACE_NAME FORMAT A15
COL D.TOT_GROOTTE_MB FORMAT A10
COL TS-PER FORMAT A15
SELECT d.tablespace_name \"Name\",
TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') \"Size (M)\",
TO_CHAR(NVL(t.hwm, 0)/1024/1024,'99999999.999')  \"HWM (M)\",
TO_CHAR(NVL(t.hwm / a.bytes * 100, 0), '990.00') \"HWM % \" ,
TO_CHAR(NVL(t.bytes/1024/1024, 0),'99999999.999') \"Using (M)\",
TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') \"Using %\"
FROM sys.dba_tablespaces d,
    (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a,
    (select tablespace_name, sum(bytes_cached) hwm, sum(bytes_used) bytes from v\\\$temp_extent_pool group by tablespace_name) t
WHERE d.tablespace_name = a.tablespace_name(+)
AND d.tablespace_name = t.tablespace_name(+)
AND d.extent_management like 'LOCAL'
AND d.contents like 'TEMPORARY';
exit;
EOF
"

echo "#######control_file############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
col name for a50
select status,name from v\\\$controlfile;
exit;
EOF
"

#echo "#######control_file_record############"
#su - oracle  -c"
#set line 300
#sqlplus -S \"/ as sysdba \" << EOF
#SELECT * FROM v\\\$CONTROLFILE_RECORD_SECTION;
#exit;
#EOF
#"
echo "#######redo_log_file############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 200
col member for a65
select a.group#,
       THREAD#,
       b.member,
       a.members,
       a.status,
       a.sequence#,
       bytes / 1024 / 1024 as file_mb
  from v\\\$log a, v\\\$logfile b
 where a.group# = b.group#
 order by 2,1;
exit;
EOF
"

echo "#######redo_switch############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set pagesize 100
select a_date,a_count from (
select to_char(first_time,'YYYY-MM-DD') a_date,count(*) a_count from gv\\\$log_history
group by to_char(first_time,'YYYY-MM-DD')
order by 1 desc) where rownum<=31;
exit;
EOF
"

echo "#######ASM_DISKGROUP############"
su - grid  -c"
sqlplus -S \"/ as sysasm \" << EOF
set line 300
col name for a10
col compatibility for a10
select group_number,
       name,
       block_size,
       total_mb,
       free_mb,
       type,
       compatibility,
       voting_files
  from v\\\$asm_diskgroup;
exit;
EOF
"
echo "#######ASM_DISK############"
su - grid  -c"
sqlplus -S \"/ as sysasm \" << EOF
set line 300
col CREATE_DATE for a10
col name for a15
col path for a20
set pagesize 300
select GROUP_NUMBER,
       DISK_NUMBER,
       STATE,
       OS_MB,
       TOTAL_MB,
       FREE_MB,
       NAME,
       PATH,
       CREATE_DATE,
       VOTING_FILE
  from v\\\$asm_disk order by 1,2;
exit;
EOF
"

echo "#######OCR_CONFIG############"
su - grid  -c"
ocrcheck -config
exit;
"

echo "#######OCR_CHECK############"
su - grid  -c"
ocrcheck
exit;
"

echo "#######OCR_BACKUP############"
su - grid  -c"
ocrconfig -showbackup
exit;
"

#echo "#######OLR_CHECK############"
#su - grid  -c"
#ocrcheck -local
#exit;
#"
echo "#######votedisk_CHECK############"
su - grid  -c"
crsctl query css votedisk
exit;
"

echo "#######OIFCFG_INFO############"
su - grid  -c"
oifcfg getif
exit;
"

echo "#######CLUSTER_CHECK############"
su - grid  -c"
crsctl check cluster -all
exit;
"

echo "#######CLUSTER_RES############"
su - grid  -c"
crsctl stat res -t
exit;
"

echo "#######CRS_CHECK############"
su - grid  -c"
crsctl check crs
exit;
"

echo "#######OHASD_CHECK############"
su - grid  -c"
crsctl check has
exit;
"

echo "#######scan config############"
su - grid  -c"
srvctl config scan
exit;
"

echo "#######scan status############"
su - grid  -c"
srvctl status scan
exit;
"

echo "#######srvctl config listener############"
su - grid  -c"
srvctl config listener -a
exit;
"

echo "#######srvctl status listener############"
su - grid  -c"
srvctl status listener
exit;
"

echo "#######DB_SECURITY_CHECK############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
column OWNER format a10        heading 'OWNER' 
column OBJECT_NAME    format a80    heading 'OBJECT_NAME' 
column OBJECT_TYPE format a40        heading 'OBJECT_TYPE' 
select OWNER,OBJECT_NAME, OBJECT_TYPE from dba_objects 
where object_name  in  
('DBMS_SUPPORT_INTERNAL','DBMS_SYSTEM_INTERNAL','DBMS_CORE_INTERNAL','DBMS_STANDARD_FUN9','DBMS_SUPPORT_INTERNAL','DBMS_SYSTEM_INTERNAL','DBMS_CORE_INTERNAL') or object_name like 'DBMS_SUPPORT_DBMONITOR%';
exit;
EOF
"

echo "#######DBA_ROLE############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select grantee,granted_role from dba_role_privs where GRANTED_ROLE='DBA';
exit;
EOF
"

echo "#######USER_PASSWORD############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
col profile for a10
select * from dba_profiles where profile='DEFAULT' and resource_name in ('PASSWORD_LIFE_TIME','FAILED_LOGIN_ATTEMPTS');
exit;
EOF
"

echo "#######DB_SIZE############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select trunc(sum(bytes) / 1024 / 1024 / 1024,2) as db_GB from dba_segments;
exit;
EOF
"

echo "#######DB_USER_SIZE############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
col owner for a15
set pagesize 100
select owner, trunc(sum(bytes) / 1024 / 1024,2) as db_MB
  from dba_segments
 group by owner
 order by 1;
exit;
EOF
"

echo "#######USER_INFO############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
set pagesize 100
col ACCOUNT_STATUS for a20
col default_tablespace for a15
col username for a10
select username,to_char(created,'YYYY-MM-DD') created,default_tablespace,ACCOUNT_STATUS from dba_users order by 2;
exit;
EOF
"

echo "#######TABLE_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
col owner for a10
select owner, count(*)
  from dba_tables
 group by owner
 order by 1;
exit;
EOF
"

echo "#######TMP_TABLE_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select owner, count(*)
  from dba_tables
 where temporary = 'Y'
 group by owner
 order by 1;
exit;
EOF
"

echo "#######INDEX_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select owner, count(*)
  from dba_indexes
 group by owner
 order by 1;
exit;
EOF
"

echo "#######VIEW_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select owner, count(*)
  from dba_views 
 group by owner
 order by 1;
exit;
EOF
"
 
echo "#######TRIGGER_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select owner, count(*)
  from dba_triggers
 group by owner
 order by 1;
exit;
EOF
"

echo "#######PROCEDURES_COUNT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
select owner, count(*)
  from dba_procedures
 group by owner
 order by 1;
exit;
EOF
"

echo "#######INVALID_OBJECTS############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 100
set pagesize 300
col owner for a20
col object_name for a30
select owner,object_type,count(*)
  from dba_objects
 where status = 'INVALID' group by owner,object_type;
exit;
EOF
"

echo "#######TABLE_PART_INFO############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 100
set pagesize 300
SELECT OWNER,TABLE_NAME,PARTITIONING_TYPE FROM DBA_PART_TABLES WHERE OWNER NOT IN ('SYS','SYSTEM') ORDER BY 1;
exit;
EOF
"

echo "#######DBA_JOBS############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
col INTERVAL for a35
col SCHEMA_USER for a15
col what for a30
SELECT job,schema_user,broken,interval,what,last_date,last_sec,BROKEN from dba_jobs;
exit;
EOF
"
 
echo "#######DBA_SCHEDULER_JOBS############"
su - oracle  -c"
sqlplus -S / as sysdba <<EOF
set line 100
col start_date for a20
select owner,job_name,job_type,start_date,state from dba_scheduler_jobs WHERE OWNER NOT IN('SYS','ORACLE_OCM');
exit;
EOF
"

echo "#######FULL_RMAN_BAK############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 150
col in_size for a10
col out_size for a10
col input_type for a10 
col e for a20
col s for a20 
select 
session_key,
input_type,
compression_ratio,
INPUT_BYTES_DISPLAY in_size,
output_bytes_display out_size,
to_char(START_TIME,'YYYYMMDD HH24:MI:SS') S,
to_char(END_TIME,'YYYYMMDD HH24:MI:SS') E,
status
from v\\\$rman_backup_job_details where INPUT_TYPE='DB FULL'
order by S DESC;
exit;
EOF
"

echo "#######INCR_RMAN_BAK############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 150
col in_size for a10
col out_size for a10
col input_type for a20 
col e for a20
col s for a20 
select 
session_key,
input_type,
compression_ratio,
INPUT_BYTES_DISPLAY in_size,
output_bytes_display out_size,
to_char(START_TIME,'YYYYMMDD HH24:MI:SS') S,
to_char(END_TIME,'YYYYMMDD HH24:MI:SS') E,
status
from v\\\$rman_backup_job_details where INPUT_TYPE='DB INCR'
order by S DESC;
exit;
EOF
"

echo "#######ARCH_RMAN_BAK############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 150
col in_size for a10
col out_size for a10
col input_type for a20 
col e for a20
col s for a20 
select 
session_key,
input_type,
compression_ratio,
INPUT_BYTES_DISPLAY in_size,
output_bytes_display out_size,
to_char(START_TIME,'YYYYMMDD HH24:MI:SS') S,
to_char(END_TIME,'YYYYMMDD HH24:MI:SS') E,
status
from v\\\$rman_backup_job_details where INPUT_TYPE='ARCHIVELOG'
order by S DESC;
exit;
EOF
"

echo "#######SESSION_INFO############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
col username for a15
select inst_id, username, count(*)
  from gv\\\$session
 group by inst_id, username
 order by 1;
exit;
EOF
"

echo "#######RESOURCE_LIMIT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 300
set pagesize 100
col RESOURCE_NAME for a10
col INITIAL_ALLOCATION for a15
select * from gv\\\$resource_limit where resource_name in ('processes','sessions');
exit;
EOF
"


###统计信息###


echo "#######11G_AUTOTASK_CLIENT############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
col CLIENT_NAME for a35
select client_name,status from dba_autotask_client;
exit;
EOF
"

echo "#######MEMORY_CONF############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
show parameter mem
show parameter sga
show parameter pga
show parameter large_pool
exit;
EOF
"

echo "#######DB_PARAMETER############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 100
set pagesize 100
col name for a30
col value for a20
col display_value for a20
col isdefault for a20
select name, value, display_value, isdefault
  from v\\\$system_parameter
 where name in ('audit_trail',
                'audit_sys_operations',
                'cluster_database_instances',
                'cpu_count',
                'cursor_sharing',
                'db_recovery_file_dest_size',
                'deferred_segment_creation',
                'disk_asynch_io',
                'event',
                'enable_ddl_logging',
                'filesystemio_options',
                'job_queue_processes',
                'log_archive_dest_1',
                'log_archive_format',
                'memory_max_target',
                'memory_target',
                'nls_language',
                'optimizer_dynamic_sampling',
                'optimizer_index_cost_adj',
                'processes',
                'parallel_force_local',
                'parallel_max_servers',
                'pga_aggregate_target',
                'query_rewrite_enabled',
                'sec_case_sensitive_logon',
                'sessions',
                'sga_max_size',
                'sga_target',
                'utl_file_dir',
                'undo_management',
                'undo_retention',
                'undo_tablespace',
                'large_pool_size',
                'resource_limit',
                'resource_manager_plan',
                'max_dump_file_size',
                'control_file_record_keep_time',
                'result_cache_max_size',
                'local_listener',
        'resource_limit') order by 1;
exit;
EOF
"

echo "#######DB_PARAMETER_2############"
su - oracle  -c"
sqlplus -S \"/ as sysdba \" << EOF
set line 200
set pagesize 100
col name for a40
col describ for a50
col value for a20
SELECT x.ksppinm  as name,
       y.ksppstvl as value,
       y.ksppstdf as isdefault,
       x.ksppdesc describ
  FROM SYS.x\\\$ksppi x, SYS.x\\\$ksppcv y
 WHERE x.inst_id = USERENV('Instance')
   AND y.inst_id = USERENV('Instance')
   AND x.indx = y.indx
   AND x.ksppinm in ('_allow_resetlogs_corruption',
                     '_b_tree_bitmap_plans',
                     '_corrupted_rollback_segments',
                     '_datafile_write_errors_crash_instance',
                     '_gc_policy_time',
                     '_gc_undo_affinity',
                     '_gc_defer_time',
                     '_hash_join_enabled',
                     '_offline_rollback_segments',
                     '_px_use_large_pool',
                     '_memory_imm_mode_without_autosga',
                     '_partition_large_extents',
                     '_optimizer_null_aware_antijoin',
                     '_optim_peek_user_binds',
                     '_optimizer_mjc_enabled',
                     '_optimizer_use_feedback',
                     '_optimizer_join_elimination_enabled',
                     '_optimizer_ads_use_result_cache',
                     '_optimizer_adaptive_plans',
                     '_optimizer_adaptive_cursor_sharing',
                     '_optimizer_extended_cursor_sharing',
                     '_optimizer_extended_cursor_sharing_rel',
                     '_optimizer_aggr_groupby_elim',
                     '_optimizer_reduce_groupby_key',
                     '_optimizer_cost_based_transformation',
                     '_use_adaptive_log_file_sync',
                     '_undo_autotune')
 order by 1;
exit;
EOF
"