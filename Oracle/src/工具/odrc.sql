prompt 
prompt 
prompt 
prompt +-----------------------------------------------------------------------+
prompt |                   ORACLE Database Recover Check                       |
prompt |-----------------------------------------------------------------------+
prompt |  Copyright (c) ohsdba. all rights reserved. (http://ohsdba.cn)        |
prompt +-----------------------------------------------------------------------+
prompt
prompt Note:you should put database in mount mode and run this script as sysdba
prompt

set termout off echo off feedback on verify off wrap on trimspool on serveroutput on long 500000000 pages 100 numw 18 escape on pages 100 lines 1000
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

column spool_time new_value _spool_time noprint
select to_char(sysdate,'yyyymmddhh24miss') spool_time from dual;
column dbname new_value _dbname noprint
select name dbname from v$database;
col error format a30

set markup html on spool on preformat off entmap on -
head ' -
  <title>ORACLE Database Recover Check Report</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#FFFFCC; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:White; background:#0066CC; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    a                 {font:10pt Arial,Helvetica,sans-serif; color:#0066CC; margin-top:0pt; margin-bottom:0pt; vertical-align:top;text-decoration: none;} -
    a.link            {font:10pt Arial,Helvetica,sans-serif; color:#0066CC; margin-top:0pt; margin-bottom:0pt; vertical-align:top;text-decoration: none;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="100%"' 

spool ODRC_&_dbname._&_spool_time..html
set markup html on entmap off
prompt <font size=+3 color=darkgreen><b>oracle database recover check</b></font><p>Copyright (c) <a target="_blank" href="http://www.ohsdba.cn">ohsdba</a>, All rights reserved.<p>

col last_time for a30
col created for a30
col start_time for a30
col controlfile_time for a30
col resetlogs_time for a30
col creation_time for a30
col checkpoint_time for a30
col online_time for a30
col unrecoverable_time for a30
col resetlogs_time for a30
col first_time for a22
col next_time for a22
col completion_time for a30
col ENABLED for a15

prompt <h1>CONTACT ME</h1>

select 'Cell' name,'18695891286' value from dual
union
select 'E-mail','ohsdba@qq.com' from dual
union
select 'WeChat','ohsdba' from dual
union
select  'XGather time',to_char(sysdate) from dual order by 1;

prompt <h1>VERSION INFO</h1>
col host_name for a15
select * from v$version;

prompt <h1>INSTANCE INFO</h1>

select instance_number,
       instance_name,
       host_name,
       status,
       startup_time start_time,
       thread#,
       database_status,
       active_state
  from gv$instance;
prompt <h1>Incarnation Info</h1>
select * from v$database_incarnation;

prompt <h1>DATABASE INFO</h1>

select dbid,
       name,
       created,
       platform_name,
       open_mode,
       log_mode,
       current_scn,
       controlfile_change#,
       checkpoint_change#,
       controlfile_type,
       controlfile_created,
       controlfile_time,
       resetlogs_change#,
       resetlogs_time
  from v$database;


prompt <h1>PARAMETER INFO</h1>
select p.name, i.instance_name, p.value
  from gv$parameter p, gv$instance i
 where p.inst_id = i.inst_id
   and isdefault = 'FALSE'
 order by p.name, i.instance_name;

prompt <h1>V$DATAFILE INFO</h1>

select ts#,
       file#,
       rfile#,
       creation_change#,
       creation_time,
       name,
       status,
       round(bytes / 1024 / 1024 / 1024, 1) "Size(G)",
       blocks,
       enabled,
       checkpoint_change#,
       checkpoint_time,
       create_bytes,
       block_size,
       unrecoverable_change#,
       unrecoverable_time,
       last_change# stop_scn,
       last_time,
       offline_change#,
       online_change#,
       online_time
  from v$datafile
 order by 1, 2;


prompt <h1>V$DATAFILE_HEADER INFO</h1>

select ts#,
       file#,
       tablespace_name,
       name,
       status,
       round(bytes / 1024 / 1024 / 1024, 1) "Size(G)",
       blocks,
       error,
       format,
       recover,
       fuzzy,
       creation_time,
       creation_change#,
       checkpoint_change#,
       checkpoint_time,
       checkpoint_count,
       resetlogs_change#,
       resetlogs_time,
       space_header
  from v$datafile_header
 order by 1, 2;


prompt <h1>SCN Info,V$DATAFILE,V$DATAFILE_HEADER</h1>
select time,
       checkpoint_change#,
       round((TotalSCN - checkpoint_change#) / (16 * 1024 * 60 * 60 * 24),1) HeadRoom,
       round((TotalSCN - checkpoint_change#) / 1024 / 1024 / 1024, 1) Adjust_SCN
  from (select to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') time,
               checkpoint_change#,
               (((((to_number(to_char(sysdate, 'YYYY')) - 1988) * 12 * 31 * 24 * 60 * 60) +
               ((to_number(to_char(sysdate, 'MM')) - 1) * 31 * 24 * 60 * 60) +
               (((to_number(to_char(sysdate, 'DD')) - 1)) * 24 * 60 * 60) +
               (to_number(to_char(sysdate, 'HH24')) * 60 * 60) +
               (to_number(to_char(sysdate, 'MI')) * 60) +
               (to_number(to_char(sysdate, 'SS')))) * (16 * 1024))) TotalSCN
          from v$database);

select 
       checkpoint_change# df_chpt_change#,
       checkpoint_time,
       last_change#,
       status,
       count(*) total
  from v$datafile
 group by checkpoint_change#, checkpoint_time, last_change#,status
 order by 1,2,4

select checkpoint_change# dh_chpt_change#, checkpoint_time, fuzzy, status, count(*) total
  from v$datafile_header
 group by status, checkpoint_change#, checkpoint_time, fuzzy
 order by 1,2;


select df.file# datafile,
       df.name,
       df.status,
       df.checkpoint_change# df_chkp,
       dh.checkpoint_change# dh_chkp,
       dh.recover,
       dh.fuzzy
  from v$datafile df, v$datafile_header dh
 where df.file# = dh.file#
   and df.checkpoint_change# <> dh.checkpoint_change#;
   
prompt <h1>X$KCVFH INFO</h1>

select fhtsn kcvfh_ts#,
       hxfil file#,
       fhrfn rfile#,
       decode(hxons, 0, 'Offline', 'Online') File_Status,
       decode(hxerr,
              0,
              null,
              1,
              'file missing',
              2,
              'offline normal',
              3,
              'not verified',
              4,
              'file not found',
              5,
              'cannot open file',
              6,
              'cannot read header',
              7,
              'corrupt header',
              8,
              'wrong file type',
              9,
              'wrong database',
              10,
              'wrong file number',
              11,
              'wrong file create',
              12,
              'wrong file create',
              16,
              'delayed open',
              14,
              'wrong resetlogs',
              15,
              'old controlfile',
              'unknown') Error,
       fhsta stautus,
       decode(hxifz, 0, 'no', 1, 'yes', null) fuzzy,
       fhcrs creat_scn,
       fhcrt creation_time,
       fhscn ckpt_scn,
       fhafs "Minimum PITR SCN",
       fhtim checkpoint_time,
       fhrls last_resetlogs_scn,
       fhthr thread#,
       fhrba_seq RBA_Seq#
  from x$kcvfh
 order by 1,2;

select fhthr kcvfh_thread,
       fhrba_seq sequence,
       fhscn scn,
       fhsta status,
       count(*) Total
  from x$kcvfh
 group by fhthr, fhrba_seq, fhscn, fhsta;

prompt <h1>REDO INFO</h1>

select thread#,
       a.group#,
       a.sequence#,
       a.bytes / 1024 / 1024 "Size(m)",
       first_change#,
       a.first_time,
       a.archived,
       a.status,
       member
  from v$log a, v$logfile b
 where a.group# = b.group#
 order by thread#, a.sequence# desc;

prompt <h1>V$ARCHIVE_DEST INFO</h1>
select
    dest_id
  , a.dest_name 
  , a.destination  
  , a.status
  , a.schedule
  , a.archiver 
  , a.log_sequence
from
    v$archive_dest a
order by
    a.dest_id;

prompt <h1>ARCHIVE LOG PARAMETER</h1>
select a.name, a.value
  from v$parameter a
 where a.name like 'log_%'
 order by a.name;
 
prompt <h1>V$ARCHIVED_LOG INFO(LATEST 200 NOT DELETED)</h1>
select *
  from (select thread#,
               sequence#,
               name,
               first_change#,
               to_char(first_time, 'yyyy-mm-dd hh24:mi:ss') first_time,
               next_change#,
               to_char(next_time, 'yyyy-mm-dd  hh24:mi:ss') next_time,
               (blocks * block_size) log_size,
               decode(status,
                      'A',
                      'AVAILABLE',
                      'D',
                      'DELETED',
                      'U',
                      'UNAVAILABLE',
                      'X',
                      'EXPIRED') status
          from gv$archived_log
         where deleted = 'NO'
         order by thread#, sequence# desc) a
 where rownum < 200;


prompt <h1>ARCHIVED LOGS(NEEDED TO COMPLETE MEDIA RECOVERY)</h1>

select a.recid,
       a.thread#,
       a.sequence#,
       a.name,
       a.first_change#,
       a.next_change#,
       a.archived,
       a.deleted,
       a.completion_time
  from v$archived_log a, v$recovery_log b
 where a.thread# = b.thread#
   and a.sequence# = b.sequence#;

prompt <h1>V$RECOVERY_LOG V$RECOVER_FILE INFO</h1>
select * from v$recovery_log order by thread#,sequence#;

select * from v$recover_file;

prompt <h1>V$BACKUP INFO</h1>
select * from v$backup;
   
prompt <h1>V$RMAN_CONFIGURATION INFO</h1>
select * from v$rman_configuration order by name;

prompt <h1>Available Backup Sets(available and expired )</h1>

select bs.recid bs_key,
       decode(backup_type,
              'L',
              'Archived redo logs',
              'D',
              'Datafile full backup',
              'I',
              'Incremental backup') backup_type,
       device_type device_type,
       decode(bs.controlfile_included, 'NO', '-', bs.controlfile_included) controlfile_included,
       nvl(sp.spfile_included, '-') spfile_included,
       bs.incremental_level incremental_level,
       bs.pieces pieces,
       to_char(bs.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
       to_char(bs.completion_time, 'yyyy-mm-dd hh24:mi:ss') completion_time,
       bs.elapsed_seconds elapsed_seconds,
       bp.tag tag,
       bs.block_size block_size,
       bs.keep keep,
       nvl(to_char(bs.keep_until, 'yyyy-mm-dd hh24:mi:ss'), '-') keep_until,
       bs.keep_options keep_options
  from v$backup_set bs,
       (select distinct set_stamp, set_count, tag, device_type
          from v$backup_piece
         where status in ('A', 'X')) bp,
       (select distinct set_stamp, set_count, 'YES' spfile_included
          from v$backup_spfile) sp
 where bs.set_stamp = bp.set_stamp
   and bs.set_count = bp.set_count
   and bs.set_stamp = sp.set_stamp(+)
   and bs.set_count = sp.set_count(+)
 order by bs.recid;

  
prompt <h1>AVAILABLE BACKUP PIECES(AVAILABLE AND EXPIRED )</h1>
SELECT bs.recid bs_key,
       bp.piece# piece#,
       bp.copy# copy#,
       bp.recid bp_key,
       DECODE(status, 'A', 'Available', 'D', 'Deleted', 'X', 'Expired') status,
       handle handle,
       TO_CHAR(bp.start_time, 'yyyy-mm-dd hh24:mi:ss') start_time,
       TO_CHAR(bp.completion_time, 'yyyy-mm-dd hh24:mi:ss') completion_time,
       bp.elapsed_seconds elapsed_seconds
  FROM v$backup_set bs, v$backup_piece bp
 WHERE bs.set_stamp = bp.set_stamp
   AND bs.set_count = bp.set_count
   AND bp.status IN ('A', 'X')
 ORDER BY bs.recid, piece#;

    
prompt <h1>RMAN BACKUP SPFILE INFO</h1>  
SELECT bs.recid bs_key,
       bp.piece# piece#,
       bp.copy# copy#,
       bp.recid bp_key,
       NVL(sp.spfile_included, '-') spfile_included,
       DECODE(status, 'A', 'Available', 'D', 'Deleted', 'X', 'Expired') status,
       handle handle
  FROM v$backup_set bs,
       v$backup_piece bp,
       (select distinct set_stamp, set_count, 'YES' spfile_included
          from v$backup_spfile) sp
 WHERE bs.set_stamp = bp.set_stamp
   AND bs.set_count = bp.set_count
   AND bp.status IN ('A', 'X')
   AND bs.set_stamp = sp.set_stamp
   AND bs.set_count = sp.set_count
 ORDER BY bs.recid, piece#;

    
    
prompt <h1>RMAN BACKUP CONTROLFILE INFO</h1>  
SELECT bs.recid bs_key,
       bp.piece# piece#,
       bp.copy# copy#,
       bp.recid bp_key,
       DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included) controlfile_included,
       DECODE(status, 'A', 'Available', 'D', 'Deleted', 'X', 'Expired') status,
       handle handle
  FROM v$backup_set bs, v$backup_piece bp
 WHERE bs.set_stamp = bp.set_stamp
   AND bs.set_count = bp.set_count
   AND bp.status IN ('A', 'X')
   AND bs.controlfile_included != 'NO'
 ORDER BY bs.recid, piece#;

    
spool off
set markup html off
host echo Please check file ODRC_&_dbname._&_spool_time..html in current directory, or sent it to ohsdba@qq.com
prompt 
prompt
host echo
exit