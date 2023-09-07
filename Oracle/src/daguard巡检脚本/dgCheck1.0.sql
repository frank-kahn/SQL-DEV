
set echo off
set feedback off
column timecol new_value timestamp
column spool_extension new_value suffix
SELECT TO_CHAR(sysdate,'mmddyyyy_hh24miss') timecol, '.html' spool_extension FROM dual;
column output new_value dbname
SELECT value || '_' output FROM v$parameter WHERE name = 'db_unique_name';
spool dgCheck_&&dbname&&timestamp&&suffix

set linesize 2000
set pagesize 50000
set numformat 999999999999999
set trim on
set trims on
set markup html on
set markup html entmap off
set feedback on
set echo on
Rem # |-------------------------------------------------------------------------------------------------------------|
Rem # |                            Database DataGuard Check Scripts V1.0
Rem # |-------------------------------------------------------------------------------------------------------------|


ALTER SESSION SET nls_date_format = 'MON-DD-YYYY HH24:MI:SS';
SELECT TO_CHAR(sysdate) time FROM dual;

set echo on
Rem ===================================
Rem 1) NAME: DATABASE_ENABLED_FEATURES
Rem ===================================

column CHECK_NAME format a40
select 'DB_ENABLED_FEATURES' as CHECK_NAME, dbid, db_unique_name, name, database_role, log_mode, force_logging, supplemental_log_data_pk, supplemental_log_data_ui, flashback_on, guard_status, dataguard_broker, protection_mode, switchover_status, dataguard_broker, platform_id, standby_became_primary_scn, primary_db_unique_name from v$database;

select sessions_current,sessions_highwater from v$license;

Rem ===================================
Rem 2) NAME:  REDO_TRANSPORT_CONFIGURED
Rem ===================================

col name format a20
col value format a2000
column CHECK_NAME format a40
select 'REDO_TRANSPORT_CONFIGURED' as CHECK_NAME, inst_id, name, value from gv$parameter where name like 'log_archive_dest_%' and upper(value) like '%SERVICE%' order by inst_id;

Rem ===================================
Rem 3) NAME: REDO_TRANSPORT_STATE_VALID
Rem ===================================

col error format a256
column CHECK_NAME format a40
select 'REDO_TRANSPORT_STATE_VALID' as CHECK_NAME, inst_id, dest_id, status, error from gv$archive_dest_status where status <> 'INACTIVE' and db_unique_name <> 'NONE' order by dest_id, inst_id;

Rem ===================================
Rem 4) NAME: SRL_SETUP
Rem ===================================

column count(*) new_value count
column CHECK_NAME format a40
select 'SRL_SETUP' as CHECK_NAME, inst_id, dest_id, standby_logfile_count from gv$archive_dest_status where status <> 'INACTIVE' and db_unique_name <> 'NONE' order by dest_id, inst_id;
select count(*) as count, 'SRL_SETUP_COUNT' as CHECK_NAME from v$log;


Rem ===================================
Rem 5) NAME: SRL_SIZES
Rem ===================================

column CHECK_NAME format a40
select distinct bytes, 'SRL_SIZES_PRIMARY' as CHECK_NAME from v$log group by bytes;
column CHECK_NAME format a40
select distinct bytes, 'SRL_SIZES_STANDBY' as CHECK_NAME from v$standby_log group by bytes;


Rem ===================================
Rem 6) NAME: ORL_and_SRL_USAGE
Rem ===================================
select * from v$log;
select GROUP#,status,type,member from v$logfile;
column CHECK_NAME format a40
column count(*) new_value count
select 'EXPECTED_SRL_USAGE' as CHECK_NAME, inst_id, dest_id, standby_logfile_active from gv$archive_dest_status where status <> 'INACTIVE' and db_unique_name <> 'NONE' order by dest_id, inst_id;
column CHECK_NAME format a40


Rem ===================================
Rem 7) NAME: GAP_STATE
Rem ===================================

column CHECK_NAME format a40
select 'GAP_STATE' as CHECK_NAME, inst_id, dest_id, db_unique_name, gap_status from gv$archive_dest_status where status <> 'INACTIVE' and db_unique_name <> 'NONE' order by dest_id, inst_id;

Rem ===================================
Rem 8) NAME: APPLY_INFO
Rem ===================================

column CHECK_NAME format a40
select 'APPLY_INFO' as CHECK_NAME, ad.dest_id, ad.applied_scn, d.current_scn from v$archive_dest ad, v$database d where ad.status <> 'INACTIVE' and ad.db_unique_name <> 'NONE' order by dest_id;

select thread#, max(sequence#) "Last Standby Seq Received" 
  from v$archived_log val, v$database vdb
  where val.resetlogs_change# = vdb.resetlogs_change#
  group by thread# order by 1;
  
select * from(select NAME,sequence#,applied from v$archived_log order by sequence# desc) where rownum<=20;

Rem ===================================
Rem 9) NAME: DATAGUARD_STATE
Rem ===================================

column CHECK_NAME format a40
column DSTIME format a25
column FACILITY format a30
column MESSAGE format a100
select 'DATAGUARD_STATE' as CHECK_NAME, inst_id, dest_id, to_char(timestamp, 'DD-MON-YYYY HH24:MI:SS') "DSTIME", facility, message from gv$dataguard_status where severity in ('Error', 'Fatal') order by dest_id, inst_id;

spool off
set markup html off entmap on