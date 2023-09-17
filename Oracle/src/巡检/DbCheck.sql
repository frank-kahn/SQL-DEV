-- |---------------------------------------------------------------------------------------|
-- |           Fgedu Oracle Database Information Collect Tools v2.6   	                   |
-- | Without the permission of the author and may not be transmitted without authorization.|
-- |   Fgedu All Study Tutorials Oracle/MySQL/NoSQL£ºhttp://www.fgedu.net.cn/oracle.html|
-- |          Copyright (c) 2008-2019,www.fgedu.net.cn Fgedu DBA Team.All rights reserved. |
-- |           Opinion Feedback: mfkqwyc86@163.com,QQ:176140749,QQ Group:150201289		   |
-- | 			      fgedu  2019-03-21   Last Updated 2.6.1					           |
-- | 			      fgedu  2015-02-12   Updated 2.5					                   |
-- | 			      fgedu  2015-01-16   Updated 2.3					                   |
-- | 			      fgedu  2014-12-26   Updated 2.2						               |
-- | 			      fgedu  2014-12-12   Updated 2.1					                   |
-- | 			      fgedu  2014-11-06   Created web2.0						           |
-- |               DBA Team  2008-01-06   Created txt1.0                  	               |
-- |---------------------------------------------------------------------------------------|
-- |         Opinion Feedback : mfkqwyc86@163.com,176140749@qq.com                         |
-- |---------------------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                                     |
-- | FILE     : dbcollect26.sql                                                            |
-- | CLASS    : Database Administration                                                    |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format) on             |
-- |            all database metrics including installed options, storage,                 |
-- |            performance data, and security.                                            |
-- | VERSION  : This script was designed for Oracle Database 11g/12c.                      |
-- |            Although this script will also work with Oracle Database 19c/18c/10g/9i    |
-- |            , several sections will error out from missing tables                      |
-- |            or columns.  													           |
-- | USAGE    :                                                                            |
-- |                                                                                       |
-- |    sqlplus -s <dba>/<password>@<TNS string> @dbcollect26.sql                          |
-- |    or:                                                                                |
-- |    sqlplus "/as sysdba" 													           |
-- |    sql>@dbcollect26.sql                                                               |
-- |                                                                                       |
-- | Comment   :                                                                           |
-- |                                                                                       |
-- |  11gR2 and 12c/18c/19c add env from grid to oracle or Manual operation:			   |
-- |  su - oracle																           |
-- |  vi .profile or .bash_profile												           |
-- |  1)add:																	           |
-- |  GRID_HOME=/oracle/app/11.2.0/grid; export GRID_HOME						           |
-- |  																			           |
-- |  2)add:																               |
-- |  $GRID_HOME/bin															           |
-- |  eg:																		           |
-- |  PATH=.:$PATH:$HOME/bin::$ORACLE_HOME/bin:$GRID_HOME/bin; export PATH		           |
-- |                                                                                       |
-- +---------------------------------------------------------------------------------------+

prompt 
prompt |-----------------------------------------------------------------------------------------|
prompt |                    Fgedu Oracle Database Information Collect Tools v2.6
prompt |-----------------------------------------------------------------------------------------|
prompt |  Without the permission of the author and may not be transmitted without authorization.
prompt |   Fgedu All Study Tutorials Oracle/MySQL/NoSQL £ºhttp://www.fgedu.net.cn/oracle.html
prompt |          Copyright (c) 2008-2019,www.fgedu.net.cn Fgedu DBA Team.All rights reserved.
prompt |           Opinion Feedback: mfkqwyc86@163.com,QQ:176140749,QQ Group:150201289 
prompt |                        	fgedu  2019-03-21   Last Updated 2.6.1       	         
prompt |                        	fgedu  2015-02-12   Updated 2.5
prompt |                        	fgedu  2015-01-16   Updated 2.3
prompt |                        	fgedu  2014-12-26   Updated 2.2		
prompt |                        	fgedu  2014-12-12   Updated 2.1	
prompt |                        	fgedu  2014-11-06   Created web2.0
prompt |	                    	DBA Team  2008-01-06   Created txt1.0
prompt |-----------------------------------------------------------------------------------------|
prompt
prompt Fgedu indicating: This script must be run as a user with SYSDBA privileges  
prompt This process can take several minutes to complete.
prompt Creating database report......                                                          
prompt 

define reportHeader="<font size=+1 color=darkgreen><b>Fgedu Oracle Database Information Collect Tools v2.6</b></font><hr>Copyright(c)2008-2019.www.fgedu.net.cn Fgedu DBA Team.Author QQ:176140749.<p>"

-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+
set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks

define fileName=dbcollect26
define versionNumber=2.3

define str_owner='owner not in (''SYS'',''SYSTEM'',''CTXSYS'',''APPQOSSYS'',''DBSNMP'',''SCOTT'',''OUTLN'',''QUEST'',''SYSMAN'',''ORDSYS'',''OLAPSYS'',''MDSYS'',''EXFSYS'',''XDB'',''CTXSYS'',''DMSYS'',''WMSYS'')'
define str_owner2='not in (''SYS'',''SYSTEM'',''CTXSYS'',''APPQOSSYS'',''DBSNMP'',''SCOTT'',''OUTLN'',''QUEST'',''SYSMAN'',''ORDSYS'',''OLAPSYS'',''MDSYS'',''EXFSYS'',''XDB'',''CTXSYS'',''DMSYS'',''WMSYS'')'
define tab_owner='table_owner not in (''SYS'',''SYSTEM'',''CTXSYS'',''APPQOSSYS'',''DBSNMP'',''SCOTT'',''OUTLN'',''SYSMAN'',''ORDSYS'',''OLAPSYS'',''MDSYS'',''EXFSYS'',''XDB'',''CTXSYS'',''DMSYS'',''WMSYS'')'

define t_str_owner='t.owner not in (''SYS'',''SYSTEM'',''CTXSYS'',''APPQOSSYS'',''DBSNMP'',''SCOTT'',''OUTLN'',''QUEST'',''SYSMAN'',''ORDSYS'',''OLAPSYS'',''MDSYS'',''EXFSYS'',''XDB'',''CTXSYS'',''DMSYS'',''WMSYS'')'
define t_tab_owner='t.table_owner not in (''SYS'',''CTXSYS'',''SYSTEM'',''APPQOSSYS'',''DBSNMP'',''SCOTT'',''OUTLN'',''SYSMAN'',''ORDSYS'',''OLAPSYS'',''MDSYS'',''EXFSYS'',''XDB'',''CTXSYS'',''DMSYS'',''WMSYS'')'

alter session set nls_date_format='yyyy.mm.dd hh24:mi:ss';

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT BASE INFORMATION                  |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone
FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN creation_date NEW_VALUE _creation_date NOPRINT
SELECT TO_CHAR(created, 'MM/DD/YYYY HH24:MI:SS') creation_date FROM v$database;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;

COLUMN db_total_gb NEW_VALUE _db_total_gb NOPRINT
select round(sum(bytes)/1024/1024/1024,2) db_total_gb from dba_data_files;

COLUMN db_used_gb NEW_VALUE _db_used_gb NOPRINT
select round(sum(bytes)/1024/1024/1024,2) db_used_gb from dba_segments;

COLUMN archivelog_mode NEW_VALUE _archivelog_mode NOPRINT
select log_mode archivelog_mode from v$database;

COLUMN user_nums NEW_VALUE _user_nums NOPRINT
select count(1) user_nums from dba_users;

COLUMN tbs_nums NEW_VALUE _tbs_nums NOPRINT
select count(1) tbs_nums from dba_tablespaces;

COLUMN dbf_nums NEW_VALUE _dbf_nums NOPRINT
select count(1) dbf_nums from dba_data_files;

COLUMN ctl_nums NEW_VALUE _ctl_nums NOPRINT
select count(1) ctl_nums from v$controlfile;

COLUMN redo_group_nums NEW_VALUE _redo_group_nums NOPRINT
select count(1) redo_group_nums from v$log;

COLUMN redo_size_mb NEW_VALUE _redo_size_mb NOPRINT
select trunc(bytes/1024/1024) redo_size_mb from v$log where rownum=1;

COLUMN redo_nums NEW_VALUE _redo_nums NOPRINT
select members redo_nums from v$log where rownum=1;

COLUMN tempfile_nums NEW_VALUE _tempfile_nums NOPRINT
select count(*) tempfile_nums from dba_temp_files;

COLUMN session_nums NEW_VALUE _session_nums NOPRINT
select count(*) session_nums from v$session where username is not null;

COLUMN db_version NEW_VALUE _db_version NOPRINT
select version db_version from v$instance;

COLUMN service_names NEW_VALUE _service_names NOPRINT
SELECT value service_names FROM v$parameter WHERE name='service_names';

COLUMN tablesize NEW_VALUE _tablesize_gb NOPRINT
COLUMN indexsize NEW_VALUE _indexsize_gb NOPRINT
select to_char(sysdate,'yyyymmdd') tjsj, dbsize,(dbsize - freesize) usedsize, (dbsize - freesize - indexsize) tablesize,indexsize
      from
       (select round(sum(bytes)/1024/1024/1024,2) as dbsize from dba_data_files),
       (select round(sum(bytes)/1024/1024/1024,2) as freesize from dba_free_space),
       (select round(sum(bytes)/1024/1024/1024,2) as indexsize from dba_segments where segment_type like '%INDEX%');

COLUMN open_mode NEW_VALUE _open_mode NOPRINT
select open_mode open_mode from v$database;

COLUMN instance_status NEW_VALUE _instance_status NOPRINT
select status instance_status FROM gv$instance;

COLUMN force_logging NEW_VALUE _force_logging NOPRINT
select force_logging force_logging from v$database;

-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on
set markup html on spool on preformat off entmap on -
head ' -
  <title>Fgedu Oracle Database Information Collect Report: &_dbname,&_spool_time</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#C0C0C0; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:#FFFFFF; background:#6666FF; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#000000; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#000000; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#000000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    tt             	  {font:9pt Arial,Helvetica,sans-serif; color:#006600;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'valign="top" WIDTH="90%" BORDER="1"' 

spool &FileName._&_instance_name._&_spool_time..html
set markup html on entmap off
-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+
prompt <a name=top></a>
prompt &reportHeader
-- +----------------------------------------------------------------------------+
-- |                             - REPORT INDEX -                               |
-- +----------------------------------------------------------------------------+
prompt <a name="report_index"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Information Collect Report</b></font></center>   
prompt <center><font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699">Database:&_dbname , Date:&_spool_time </font></center> 
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Index</b></font><hr align="center" width="250"></center> -
<table width="99%" border="1"> -
<tr><th colspan="3">1.Database and Instance Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#report_header">1.1 Database and Instance Information</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#initialization_parameters">1.2 Initialization Parameters</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#profiles_parameters">1.3 Profiles Parameters</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#props_Information">1.4 Props Information</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#control_files">1.5 Control Files</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#online_redo_logs">1.6 Online Redo Logs</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#redo_log_switches">1.7 Redo Log Switches</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#archiving_mode">1.8 Archiving Mode</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#archive_destinations">1.9 Archive Destinations</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#archiving_instance_parameters">1.10 Archiving Instance Parameters</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#archiving_history">1.11 Archiving History</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dataguard_status">1.12 DataGuard Status</a></td> -
</tr> 

prompt -
<tr><th colspan="3"></th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#flashback_database_parameters">1.13 Flashback Database Parameters</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#flash_recovery_area_status">1.14 Flash Recovery Area Status</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#database_options">1.15 Database Options</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#database_registry">1.16 Database Registry</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#feature_usage_statistics">1.17 Feature Usage Statistics</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#scn_healthcheck">1.18 Scn HealthCheck</a></td> -
</tr>

prompt -
<tr><th colspan="3">2. Database Storage Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#asm_disk_info">2.1 Asm Disk Info</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#asm_diskgroup_info">2.2 Asm Diskgroup Info</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#tablespaces">2.3 Tablespaces</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#data_files">2.4 Data Files</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#temp_files">2.5 Temp File</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#data_files_header">2.6 Data Files Header</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#database_growth">2.7 Database Growth</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#owner_data_size">2.8 Owner Data Size</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#owner_to_tablespace">2.9 Owner to Tablespace</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#undo_retention_parameters">2.10 UNDO Retention Parameters</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#undo_segments">2.11 UNDO Segments</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#undo_segment_contention">2.12 UNDO Segment Contention</a></td> -
</tr>

prompt -
<tr><th colspan="3">3. Database  Objects Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#user_accounts">3.1 User Accounts</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#users_with_dba_privileges">3.2 Users With DBA Privileges</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#User_Priv">3.3 User Priv</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#roles">3.4 Roles</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#default_passwords">3.5 Default Passwords</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#db_links">3.6 DB Links</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#scheduler_jobs">3.7 Scheduler Jobs</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#object_summary">3.8 Object Summary</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#segment_summary">3.9 Segment Summary</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#invalid_objects">3.10 Invalid Objects</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#procedural_object_errors">3.11 Procedural Object Errors</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#collect_analyazed_info">3.12 Collect Analyazed Tables and Indexex</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#public_synonym">3.13Public Synonym</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#trigger_check">3.14 Trigger Check</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#disabled_constraints">3.15 Disabled Constraints</a></td> -
</tr>

prompt -
<tr><th colspan="3"></th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#Indexes_Foreign_Key">3.16 Indexes Foreign Key</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Tables_With_No_Logging">3.17 Tables With No Logging</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_lob_segments">3.18 LOB Segments</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#users_with_default_tablespace_defined_as_system">3.19 Users With Default Tablespace - (SYSTEM)</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#users_with_default_temporary_tablespace_as_system">3.20 Users With Default Temporary Tablespace - (SYSTEM)</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_enabled_traces">3.21 Objects in the SYSTEM Tablespace</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#no-primary-key-table">3.22 NO-Primary-Key Table</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#mviews_list">3.23 Materialized Vier</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_recycle_bin">3.24 Recycle Bin</a></td> -
</tr>

prompt -
<tr><th colspan="3">4. Database  Backup Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_backup_jobs">4.1 RMAN Backup Jobs</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_configuration">4.2 RMAN Configuration</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_backup_sets">4.3 RMAN Backup Sets</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_backup_pieces">4.4 RMAN Backup Pieces</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_backup_control_files">4.5 RMAN Backup Control Files</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#rman_backup_spfile">4.6 RMAN Backup SPFILE</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_directories">4.7 Directories</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_directory_privileges">4.8 Directory Privileges</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#data_pump_jobs">4.9 Data Pump Jobs</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#data_pump_sessions">4.10 Data Pump Sessions</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#data_pump_job_progress">4.11 Data Pump Job Progress</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#"><br></a></td> -
</tr>

prompt -
<tr><th colspan="3">5. Database Performance Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#wait_event_Summary">5.1 Wait Event Summary</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#current_sessions">5.2 Current Sessions</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#locking_information">5.3 Locking Information Medium Detail</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#sga_information">5.4 SGA Information</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#sga_asmm_dynamic_components">5.5 SGA (ASMM) Dynamic Components</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#pga_target_advice">5.6 PGA Target Advice</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#awr_snapshot_list">5.7 AWR Snapshot List</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#awr_snapshot_size_estimates">5.8 AWR Snapshot Size Estimates</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#file_io_statistics">5.9 File IO Statistics</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#file_io_timings">5.10 File IO Timings</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#index_table_degree_check">5.11 Index and Table Degree Check</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#full_table_scans">5.12 Full Table Scans</a></td> -
</tr>

prompt -
<tr><th colspan="3"></th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#sorts">5.13 Sorts</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#dba_outline_hints">5.14 Outline Hints</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#high_water_mark_statistics">5.15 High Water Mark Statistics</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#tables_suffering_from_row_chaining_migration">3.16 Tables Suffering From Row Migration</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#sql_statements_by_elapsed_time">5.17 SQL Statements by Elapsed Time</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#sql_statements_by_excutions">5.18 SQL SQL Statements by Executions</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#sql_statements_by_disk_reads">5.19 SQL Statements by Disk Reads</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#sql_statements_by_buffer_gtes">5.20 SQL Statements by Buffer Gets</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#"><br></a></td> -
</tr>

prompt -
<tr><th colspan="3">6. Operating System Information</th></tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#Listener_And_Tnsnames">6.1 Listener And Tnsnames</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Oracle_Opatch">6.2 Oracle Opatch</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Oracle_Processes">6.3 Oracle Processes</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#Oracle_Clusterware">6.4 Oracle Clusterware</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#profile_and_crontab">6.5 Profile and Crontab</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#FileSystem">6.6 FileSystem</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#OS_Version">6.7 OS Version</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Os_Hosts">6.8 OS_etc_Hosts</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Os_ip_route">6.9 OS_ip_route</a></td> -
</tr> -
<tr> -
<td nowrap align="left" width="33%"><a class="link" href="#OS_Swapinfo">6.10 OS Swapinfo</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#OS_Vmstat">6.11 OS Vmstate</a></td> -
<td nowrap align="left" width="33%"><a class="link" href="#Hardware_Information">6.12 Hardware Information</a></td> -
</tr> -
</table>

prompt <p>

set termout       ON
prompt 5% Collect Database and Instance Information...... 
set termout       off 
-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database and Instance Information    >>>>>                |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database and Instance Information</u></b></font></center>

-- +----------------------------------------------------------------------------+
-- |                            - Database Base Information -                   |
-- +----------------------------------------------------------------------------+

prompt 
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Base Information</b></font><hr align="left" width="460">
prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_instance_name._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Report Run Date/Time/Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Version</th><td width="80%"><tt>&_db_version</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database Creation Date</th><td width="80%"><tt>&_creation_date</tt></td></tr> -
<tr><th align="left" width="20%">Database_Open_Mode</th><td width="80%"><tt>&_open_mode</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Services Name</th><td width="80%"><tt>&_service_names</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Status</th><td width="80%"><tt>&_instance_status</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Instance Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> 
prompt -
<tr></tr> -
<tr><th align="left" width="20%">Archive Log Mode</th><td width="80%"><tt>&_archivelog_mode</tt></td></tr> -
<tr><th align="left" width="20%">Force Logging </th><td width="80%"><tt>&_force_logging</tt></td></tr> -
<tr><th align="left" width="20%">Database Toltal Size(gb)</th><td width="80%"><tt>&_db_total_gb</tt></td></tr> -
<tr><th align="left" width="20%">Data Toltal Size(gb)</th><td width="80%"><tt>&_db_used_gb</tt></td></tr> -
<tr><th align="left" width="20%">Database Table Size(gb)</th><td width="80%"><tt>&_tablesize_gb</tt></td></tr> -
<tr><th align="left" width="20%">Database Index Size(gb)</th><td width="80%"><tt>&_indexsize_gb</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">db_block_size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">User Count</th><td width="80%"><tt>&_user_nums</tt></td></tr> -
<tr><th align="left" width="20%">Datafile Count</th><td width="80%"><tt>&_dbf_nums</tt></td></tr> -
<tr><th align="left" width="20%">Tempfile Count</th><td width="80%"><tt>&_tempfile_nums</tt></td></tr> -
<tr><th align="left" width="20%">Control Count</th><td width="80%"><tt>&_ctl_nums</tt></td></tr> -
<tr><th align="left" width="20%">RedoLog Group Count</th><td width="80%"><tt>&_redo_group_nums</tt></td></tr> -
<tr><th align="left" width="20%">RedoLog Size(mb)</th><td width="80%"><tt>&_redo_size_mb</tt></td></tr> -
<tr><th align="left" width="20%">RedoLog Count</th><td width="80%"><tt>&_redo_nums</tt></td></tr> -
<tr><th align="left" width="20%">Session Count</th><td width="80%"><tt>&_session_nums</tt></td></tr> -
</table>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                FORMAT a20    HEADING 'Name'    ENTMAP off
COLUMN current_scn       FORMAT 99999999999999999999999    HEADING 'Current_Scn'    ENTMAP off
COLUMN platform_name       FORMAT a50               HEADING 'Platform_Name' ENTMAP off
COLUMN platform_id       FORMAT 999               HEADING 'Platform_ID' ENTMAP off
COLUMN LOG_MODE       FORMAT a50               HEADING 'Archive_Mode' ENTMAP off
COLUMN flashback_on       FORMAT a20               HEADING 'Flashback_ON' ENTMAP off

BREAK ON report

select name,dbid,current_scn,LOG_MODE,flashback_on,platform_name,platform_id from v$database;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- SET TIMING ON

-- +----------------------------------------------------------------------------+
-- |                       - INITIALIZATION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="initialization_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Initialization Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN spfile  HEADING 'SPFILE Usage'

SELECT
  'This database '||
  DECODE(   (1-SIGN(1-SIGN(count(*) - 0)))
          , 1
          , '<font color="#663300"><b>IS</b></font>'
          , '<font color="#990000"><b>IS NOT</b></font>') ||
  ' using an SPFILE.'spfile
FROM v$spparameter
WHERE value IS NOT null;

prompt <tr><th align="left"><b>Part Write a report:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>

COLUMN pname                FORMAT a75    HEADING 'Parameter Name'    ENTMAP off
COLUMN value                FORMAT a75    HEADING 'Value'             ENTMAP off
COLUMN isdefault            FORMAT a75    HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable     FORMAT a75    HEADING 'Is Dynamic?'       ENTMAP off

BREAK ON report ON pname

SELECT DECODE(p.isdefault,
              'FALSE',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>',
              '<b><font color="#336699">' || SUBSTR(p.name, 0, 512) ||
              '</font></b>') pname,
       DECODE(p.isdefault,
              'FALSE',
              '<font color="#663300"><b>' || SUBSTR(p.value, 0, 512) ||
              '</b></font>',
              SUBSTR(p.value, 0, 512)) value,
       DECODE(p.isdefault,
              'FALSE',
              '<div align="center"><font color="#663300"><b>' || p.isdefault ||
              '</b></font></div>',
              '<div align="center">' || p.isdefault || '</div>') isdefault,
       DECODE(p.isdefault,
              'FALSE',
              '<div align="right"><font color="#663300"><b>' ||
              p.issys_modifiable || '</b></font></div>',
              '<div align="right">' || p.issys_modifiable || '</div>') issys_modifiable
  FROM v$parameter p
 WHERE p.name in ('background_dump_dest',
                  'compatible',
                  'control_files',
                  'core_dump_dest',
                  'db_block_size',
                  'db_cache_size',
                  'db_domain',
                  'db_file_multiblock_read_count',
                  'db_name',
                  'fast_start_mttr_target',
                  'global_names',
                  'hash_join_enabled',
                  'instance_name',
                  'java_pool_size',
                  'job_queue_processes',
                  'large_pool_size',
                  'log_buffer',
                  'log_checkpoint_interval',
                  'log_checkpoint_timeout',
                  'open_cursors',
                  'open_links',
                  'open_links_per_instance',
                  'pga_aggregate_target',
                  'processes',
                  'query_rewrite_enabled',
                  'shared_pool_size',
                  'sort_area_retained_size',
                  'sort_area_size',
                  'star_transformation_enabled',
                  'timed_statistics',
                  'undo_management',
                  'undo_retention',
                  'undo_tablespace',
                  'user_dump_dest',
                  'workarea_size_policy',
                  'db_recovery_file_dest_size',
                  'db_recovery_file_dest',
                  'service_names',
                  'sga_max_size',
                  'sga_target',
                  'streams_pool_size',
                  'log_archive_dest',
                  'cursor_sharing',
                  'session_cached_cursors',
                  'cluster_interconnects',
                  'shared_pool_reserved_size',
                  'db_keep_cache_size',
                  'aq_tm_processes',
                  'audit_sys_operations',
                  'audit_trail',
                  'cluster_database',
                  'control_file_record_keep_time',
                  'cpu_count',
                  'db_files',
                  'db_flashback_retention_target',
                  'db_writer_processes',
                  'gcs_server_processes',
                  'log_archive_dest_1',
                  'parallel_max_servers')
 order by p.name;


prompt <tr><th align="left"><b>ALL:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>

COLUMN pname                FORMAT a75    HEADING 'Parameter Name'    ENTMAP off
COLUMN instance_name_print  FORMAT a45    HEADING 'Instance Name'     ENTMAP off
COLUMN value                FORMAT a75    HEADING 'Value'             ENTMAP off
COLUMN isdefault            FORMAT a75    HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable     FORMAT a75    HEADING 'Is Dynamic?'       ENTMAP off

BREAK ON report ON pname

SELECT
    DECODE(   p.isdefault
            , 'FALSE'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>' )    pname
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || i.instance_name || '</b></font>'
            , i.instance_name )                                                         instance_name_print
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || SUBSTR(p.value,0,512) || '</b></font>'
            , SUBSTR(p.value,0,512) ) value
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="center"><font color="#663300"><b>' || p.isdefault || '</b></font></div>'
            , '<div align="center">'                          || p.isdefault || '</div>')                         isdefault
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || p.issys_modifiable || '</b></font></div>'
            , '<div align="right">'                          || p.issys_modifiable || '</div>')                  issys_modifiable
FROM
    gv$parameter p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    p.name
  , i.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                       - Profiles Parameters -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="profiles_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Profiles Parameters</b></font><hr align="left" width="460">
prompt <tr><th align="left"><b>Note£ºif PASSWORD_LIFE_TIME=180,Need to modify UNLIMITED,cmd:Alter PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED; </b></th><tr>

CLEAR COLUMNS BREAKS COMPUTES

SELECT * FROM dba_profiles;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                       - PROPS$ Information -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="props_Information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>PROPS$ Information</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES


COLUMN PROPS_NAME              FORMAT a50    HEADING 'Parameter Name'    ENTMAP off
COLUMN VALUE  				   FORMAT a50    HEADING 'VALUE'     ENTMAP off
COLUMN COMMENT                 FORMAT a75    HEADING 'Parameter COMMENT'             ENTMAP off

BREAK ON report ON NAME

select     '<div align="left"><font color="#336699"><b>' || NAME || '</b></font></div>'         PROPS_NAME
			,VALUE$ VALUE,COMMENT$ from props$;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                            - CONTROL FILES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                           HEADING 'Controlfile Name'  ENTMAP off
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP off
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'                                                                      name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
  , '<div align="right">' || TO_CHAR(block_size *  file_size_blks, '999,999,999,999') || '</div>'    file_size
FROM 
    v$controlfile c
ORDER BY
    c.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a95                HEADING 'Instance Name'    ENTMAP off
COLUMN thread_number_print  FORMAT a95                HEADING 'Thread Number'    ENTMAP off
COLUMN groupno                                        HEADING 'Group Number'     ENTMAP off
COLUMN member                                         HEADING 'Member'           ENTMAP off
COLUMN redo_file_type       FORMAT a75                HEADING 'Redo Type'        ENTMAP off
COLUMN log_status           FORMAT a75                HEADING 'Log Status'       ENTMAP off
COLUMN bytes                FORMAT 999,999,999,999    HEADING 'Bytes(MB)'            ENTMAP off
COLUMN archived             FORMAT a75                HEADING 'Archived?'        ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">' || i.thread# || '</div>'                                                  thread_number_print
  , f.group#                                                                                         groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes/1024/1024                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    gv$logfile  f
  , gv$log      l
  , gv$instance i
WHERE
      f.group#  = l.group#
  AND l.thread# = i.thread#
  AND i.inst_id = f.inst_id
  AND f.inst_id = l.inst_id
ORDER BY
    i.instance_name
  , f.group#
  , f.member;


CLEAR COLUMNS BREAKS COMPUTES
COLUMN bytes                FORMAT 9999999999999999999     HEADING 'Bytes'            ENTMAP off
COLUMN FIRST_CHANGE#        FORMAT 9999999999999999999     HEADING 'FIRST_CHANGE#'         ENTMAP off
COLUMN NEXT_CHANGE#         FORMAT 9999999999999999999     HEADING 'NEXT_CHANGE#'         ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT * FROM gv$log;
  
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - REDO LOG SWITCHES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="redo_log_switches"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Switches</b></font><hr align="left" width="460">

prompt <b>The last 30 days:</b>
CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL FORMAT 999,999,999      HEADING 'TOTAL_Count'       ENTMAP off


BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' avg label '<font color="#990000"><b>Average:</b></font>' OF total ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH:MI:SS'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history a
  where a.FIRST_TIME > sysdate - 30
GROUP BY SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(a.first_time, 'MM/DD/RR HH:MI:SS'),1,5)
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                             - ARCHIVING MODE -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_mode"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Mode</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN db_log_mode                  FORMAT a95                HEADING 'Database|Log Mode'             ENTMAP off
COLUMN log_archive_start            FORMAT a95                HEADING 'Automatic|Archival'            ENTMAP off
COLUMN oldest_online_log_sequence   FORMAT 999999999999999    HEADING 'Oldest Online |Log Sequence'   ENTMAP off
COLUMN current_log_seq              FORMAT 999999999999999    HEADING 'Current |Log Sequence'         ENTMAP off

SELECT
    '<div align="center"><font color="#663300"><b>' || d.log_mode           || '</b></font></div>'    db_log_mode
  , '<div align="center"><font color="#663300"><b>' || p.log_archive_start  || '</b></font></div>'    log_archive_start
  , c.current_log_seq                                   current_log_seq
  , o.oldest_online_log_sequence                        oldest_online_log_sequence
FROM
    (select
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Archive Mode'
                 , 'NOARCHIVELOG', 'No Archive Mode'
                 , log_mode
         )   log_mode
     from v$database
    ) d
  , (select
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Enabled'
                 , 'NOARCHIVELOG', 'Disabled')   log_archive_start
     from v$database
    ) p
  , (select a.sequence#   current_log_seq
     from   v$log a
     where  a.status = 'CURRENT'
       and thread# = &_thread_number
    ) c
  , (select min(a.sequence#) oldest_online_log_sequence
     from   v$log a
     where  thread# = &_thread_number
    ) o
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                         - ARCHIVE DESTINATIONS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="archive_destinations"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archive Destinations</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dest_id                                                HEADING 'Destination|ID'            ENTMAP off
COLUMN dest_name                                              HEADING 'Destination|Name'          ENTMAP off
COLUMN destination                                            HEADING 'Destination'               ENTMAP off
COLUMN status                                                 HEADING 'Status'                    ENTMAP off
COLUMN schedule                                               HEADING 'Schedule'                  ENTMAP off
COLUMN archiver                                               HEADING 'Archiver'                  ENTMAP off
COLUMN log_sequence                 FORMAT 999999999999999    HEADING 'Current Log|Sequence'      ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || a.dest_id || '</b></font></div>'    dest_id
  , a.dest_name                               dest_name
  , a.destination                             destination
  , DECODE(   a.status
            , 'VALID',    '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INACTIVE', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,             '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , DECODE(   a.schedule
            , 'ACTIVE',   '<div align="center"><b><font color="darkgreen">' || schedule || '</font></b></div>'
            , 'INACTIVE', '<div align="center"><b><font color="#990000">'   || schedule || '</font></b></div>'
            ,             '<div align="center"><b><font color="#663300">'   || schedule || '</font></b></div>' ) schedule
  , a.archiver                                archiver
  , a.log_sequence                            log_sequence
FROM
    v$archive_dest a
ORDER BY
    a.dest_id
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - ARCHIVING INSTANCE PARAMETERS -                       |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_instance_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Instance Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name      HEADING 'Parameter Name'   ENTMAP off
COLUMN value     HEADING 'Parameter Value'  ENTMAP off

SELECT
    '<b><font color="#336699">' || a.name || '</font></b>'    name
  , a.value                                                   value
FROM
    v$parameter a
WHERE
    a.name like 'log_%'
ORDER BY
    a.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                           - ARCHIVING HISTORY -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_history"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving History</b></font><hr align="left" width="460">

prompt <b>The last 30 days:</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL_Count FORMAT 999,999,999      HEADING 'TOTAL_Count'       ENTMAP off
COLUMN TOTAL_Size FORMAT 999,999,999      HEADING 'TOTAL_Size'       ENTMAP off


SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR( TO_CHAR(first_time,'MM/DD'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'00',1,0)) H00
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'01',1,0)) H01
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'02',1,0)) H02
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'03',1,0)) H03
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'04',1,0)) H04
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'05',1,0)) H05
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'06',1,0)) H06
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'07',1,0)) H07
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'08',1,0)) H08
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'09',1,0)) H09
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'10',1,0)) H10
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'11',1,0)) H11
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'12',1,0)) H12
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'13',1,0)) H13
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'14',1,0)) H14
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'15',1,0)) H15
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'16',1,0)) H16
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'17',1,0)) H17
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'18',1,0)) H18
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'19',1,0)) H19
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'20',1,0)) H20
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'21',1,0)) H21
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'22',1,0)) H22
  , SUM(DECODE(TO_CHAR(first_time, 'HH24'),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL_Count
  , '<div align="right"><font color="#336699"><b>' ||trim(to_char(sum(blocks*block_size)/1024/1024/1024,'99,999.9'))||'G </b></font></div>'  TOTAL_Size
  FROM
  (select max(blocks) blocks,max(block_size) block_size,max(first_time) first_time
  from
  v$archived_log  a
  where COMPLETION_TIME > sysdate - 30
    and dest_id = 1
  group by sequence#
)
 group by  TO_CHAR(first_time,'MM/DD')
order by TO_CHAR(first_time,'MM/DD') desc;
/


prompt <b>The last rownum < 101:</b>

COLUMN thread#          FORMAT a79                   HEADING 'Thread#'           ENTMAP off
COLUMN sequence#        FORMAT a79                   HEADING 'Sequence#'         ENTMAP off
COLUMN name                                          HEADING 'Name'              ENTMAP off
COLUMN first_change#                                 HEADING 'First|Change #'    ENTMAP off
COLUMN first_time       FORMAT a75                   HEADING 'First|Time'        ENTMAP off
COLUMN next_change#                                  HEADING 'Next|Change #'     ENTMAP off
COLUMN next_time        FORMAT a75                   HEADING 'Next|Time'         ENTMAP off
COLUMN log_size         FORMAT 999,999,999,999,999   HEADING 'Size_MB'   ENTMAP off
COLUMN archived         FORMAT a31                   HEADING 'Archived?'         ENTMAP off
COLUMN applied          FORMAT a31                   HEADING 'Applied?'          ENTMAP off
COLUMN deleted          FORMAT a31                   HEADING 'Deleted?'          ENTMAP off
COLUMN status           FORMAT a75                   HEADING 'Status'            ENTMAP off

BREAK ON report ON thread#

SELECT
    '<div align="center"><b><font color="#336699">' || thread#   || '</font></b></div>'  thread#
  , '<div align="center"><b><font color="#336699">' || sequence# || '</font></b></div>'  sequence#
  , name
  , first_change#
  , '<div align="right" nowrap>' || TO_CHAR(first_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>' first_time
  , next_change#
  , '<div align="right" nowrap>' || TO_CHAR(next_time, 'mm/dd/yyyy HH24:MI:SS')  || '</div>' next_time
  , round((blocks*block_size)/1024/1024,2)                           log_size  
  , DECODE(   archived
            , 'YES'
            , '<div align="center"><font color="darkgreen">'  || archived || '</font></div>'
            , '<div align="center"><font color="red">'  || archived || '</font></div>') archived
    , DECODE(   applied
            , 'YES'
            , '<div align="center"><font color="darkgreen">'  || applied || '</font></div>'
            , '<div align="center"><font color="red">'  || applied || '</font></div>') applied
  , DECODE(   deleted
            , 'NO'
            , '<div align="center"><font color="darkgreen">'  || deleted || '</font></div>'
            , '<div align="center"><font color="red">'  || deleted || '</font></div>') deleted
  , DECODE(   status
            , 'A', '<div align="center"><b><font color="darkgreen">Available</font></b></div>'
            , 'D', '<div align="center"><b><font color="#663300">Deleted</font></b></div>'
            , 'U', '<div align="center"><b><font color="#990000">Unavailable</font></b></div>'
            , 'X', '<div align="center"><b><font color="#990000">Expired</font></b></div>'
    ) status
FROM
    v$archived_log
WHERE
    status in ('A')
	and 
	rownum < 101
ORDER BY
    thread#
  , sequence#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                                 - DataGuard STATUS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="dataguard_status"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dataguard Status</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES
 
  select name,
       db_unique_name,
       database_role,
       open_mode,
	   '<div nowrap><b><font color="#990000">' || log_mode || '</font></b></div>'  log_mode
       ,protection_mode,
       current_scn,
       archivelog_change#,
	   '<div nowrap><b><font color="#990000">' || switchover_status || '</font></b></div>'  switchover_status
	   ,dataguard_broker
  from gv$database;

CLEAR COLUMNS BREAKS COMPUTES  
select client_process,
       process,
       sequence#,
       '<div nowrap><b><font color="#990000">' || status || '</font></b></div>' status
  from gv$managed_standby;


prompt <b>Last 2 day Status:</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN SEVERITY      HEADING 'SEVERITY'      ENTMAP off
COLUMN ERROR_CODE   FORMAT 999999999999          HEADING 'ERROR_CODE?'       ENTMAP off

SELECT ERROR_CODE
	,DECODE(   SEVERITY
            , 'Warning'
            , '<div align="center"><b><font color="#000099">'   || SEVERITY || '</font></b></div>'
            , 'Error'
            , '<div align="center"><b><font color="#990000">'   || SEVERITY || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || SEVERITY || '</font></b></div>'
    ) 																				SEVERITY
   	,TO_cHAR(TIMESTAMP, 'DD-MON-RR HH24:MI:SS') TIMESTAMP
   ,MESSAGE                                                                                  
FROM gv$DATAGUARD_STATUS
WHERE CALLOUT='YES'
AND TIMESTAMP > SYSDATE-2
AND SEVERITY not in ('Informational');

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                     - FLASHBACK DATABASE PARAMETERS -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="flashback_database_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flashback Database Parameters</b></font><hr align="left" width="460">

prompt <b>db_flashback_retention_target is specified in minutes</b>
prompt <b>db_recovery_file_dest_size is specified in GB</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value and Size_GB'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'db_recovery_file_dest_size'    THEN '<div nowrap align="right">' || TO_CHAR(p.value/1024/1024/1024, '999,999,999,999,999') || '</div>'
         WHEN 'db_flashback_retention_target' THEN '<div nowrap align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || NVL(p.value, '(null)') || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('db_flashback_retention_target', 'db_recovery_file_dest_size', 'db_recovery_file_dest')
ORDER BY
    1
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                      - FLASH RECOVERY AREA STATUS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="flash_recovery_area_status"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flash Recovery Area Status</b></font><hr align="left" width="460">

prompt <b>Current location, disk quota, space in use, space reclaimable by deleting files, and number of files in the Flash Recovery Area</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               FORMAT a75                  HEADING 'Name'               ENTMAP off
COLUMN space_limit        FORMAT 99,999,999,999,999   HEADING 'Space_Limit_GB'        ENTMAP off
COLUMN space_used         FORMAT 99,999,999,999,999   HEADING 'Space_Used GB'         ENTMAP off
COLUMN space_used_pct     FORMAT 999.99               HEADING '% Used'             ENTMAP off
COLUMN space_reclaimable  FORMAT 99,999,999,999,999   HEADING 'Space_Reclaimable_GB'  ENTMAP off
COLUMN pct_reclaimable    FORMAT 999.99               HEADING '% Reclaimable'      ENTMAP off
COLUMN number_of_files    FORMAT 999,999              HEADING 'Number of Files'    ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || name || '</b></font></div>'    name
  , space_limit/1024/1024/1024                                                                       space_limit
  , '<div align="center"><font color="#E56600"><b>' || ROUND(space_used/1024/1024/1024, 2)  || '</b></font></div>'    space_used                                                                      
  , ROUND((space_used / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2)        space_used_pct
  , space_reclaimable/1024/1024/1024                                                                 space_reclaimable
  , ROUND((space_reclaimable / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2) pct_reclaimable
  , number_of_files                                                                   number_of_files
FROM
    v$recovery_file_dest
ORDER BY
    name;


CLEAR COLUMNS BREAKS COMPUTES

COLUMN file_type                  FORMAT a75     HEADING 'File Type'

COLUMN percent_space_used                        HEADING 'Percent Space Used(%)'
COLUMN percent_space_reclaimable                 HEADING 'Percent Space Reclaimable(%)'
COLUMN number_of_files            FORMAT 999,999 HEADING 'Number of Files'

SELECT
    '<div align="center"><font color="#336699"><b>' || file_type || '</b></font></div>' file_type
   , '<div align="right"><font color="#E56600"><b>' || percent_space_used  || '</b></font></div>'   percent_space_used                                                                      
  , percent_space_reclaimable                                                           percent_space_reclaimable
  , number_of_files                                                                     number_of_files
FROM
    v$flash_recovery_area_usage;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                                 - Database OPTIONS                         |
-- +----------------------------------------------------------------------------+

prompt <a name="database_options"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Options</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN parameter      HEADING 'Option Name'      ENTMAP off
COLUMN value          HEADING 'Installed?'       ENTMAP off

SELECT
    DECODE(   value
            , 'FALSE'
            , '<b><font color="#336699">' || parameter || '</font></b>'
            , '<b><font color="#336699">' || parameter || '</font></b>') parameter
  , DECODE(   value
            , 'FALSE'
            , '<div align="center"><font color="#990000"><b>' || value || '</b></font></div>'
            , '<div align="center">' || value || '</div>' ) value
FROM v$option
ORDER BY parameter;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - DATABASE REGISTRY -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="database_registry"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Registry</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES
COLUMN ACTION_TIME       FORMAT 99999999999999999   HEADING 'Action_Time'       ENTMAP off
COLUMN action       FORMAT a50   HEADING 'Action'       ENTMAP off
COLUMN comments     FORMAT a100   HEADING 'Aomments'     ENTMAP off

select ACTION_TIME ACTION_TIME
	,action action
	,NAMESPACE
	,comments  comments
	,BUNDLE_SERIES
from 
registry$history;


CLEAR COLUMNS BREAKS COMPUTES

COLUMN comp_id       FORMAT a75   HEADING 'Component ID'       ENTMAP off
COLUMN comp_name     FORMAT a75   HEADING 'Component Name'     ENTMAP off
COLUMN version                    HEADING 'Version'            ENTMAP off
COLUMN status        FORMAT a75   HEADING 'Status'             ENTMAP off
COLUMN modified      FORMAT a75   HEADING 'Modified'           ENTMAP off
COLUMN control                    HEADING 'Control'            ENTMAP off
COLUMN schema                     HEADING 'Schema'             ENTMAP off
COLUMN procedure                  HEADING 'Procedure'          ENTMAP off

SELECT
    '<font color="#336699"><b>' || comp_id    || '</b></font>' comp_id
  , '<div nowrap>' || comp_name || '</div>'                    comp_name
  , version
  , DECODE(   status
            , 'VALID',   '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INVALID', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,            '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , '<div nowrap align="right">' || modified || '</div>'                      modified
  , control
  , schema
  , procedure
FROM dba_registry
ORDER BY comp_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                       - FEATURE USAGE STATISTICS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="feature_usage_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Feature Usage Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN feature_name          FORMAT a115    HEADING 'Feature|Name'
COLUMN version               FORMAT a75     HEADING 'Version'
COLUMN detected_usages       FORMAT a75     HEADING 'Detected|Usages'
COLUMN total_samples         FORMAT a75     HEADING 'Total|Samples'
COLUMN currently_used        FORMAT a60     HEADING 'Currently|Used'
COLUMN first_usage_date      FORMAT a95     HEADING 'First Usage|Date'
COLUMN last_usage_date       FORMAT a95     HEADING 'Last Usage|Date'
COLUMN last_sample_date      FORMAT a95     HEADING 'Last Sample|Date'
COLUMN next_sample_date      FORMAT a95     HEADING 'Next Sample|Date'

SELECT
    '<div align="left"><font color="#336699"><b>' || name || '</b></font></div>'      feature_name
  , DECODE(   detected_usages
            , 0
            , version 
            , '<font color="#663300"><b>' || version || '</b></font>')                  version
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(detected_usages), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(detected_usages), '<br>') || '</b></font></div>') detected_usages
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(total_samples), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(total_samples), '<br>') || '</b></font></div>')   total_samples
  , DECODE(   detected_usages
            , 0
            , '<div align="center">' || NVL(currently_used, '<br>') || '</div>'
            , '<div align="center"><font color="#663300"><b>' || NVL(currently_used, '<br>') || '</b></font></div>')           currently_used
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(first_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(first_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   first_usage_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(last_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(last_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')    last_usage_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(last_sample_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(last_sample_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   last_sample_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR((last_sample_date+SAMPLE_INTERVAL/60/60/24), 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR((last_sample_date+SAMPLE_INTERVAL/60/60/24), 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   next_sample_date
FROM dba_feature_usage_statistics
ORDER BY name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                       - Scn_HealthCheck -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="scn_healthcheck"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Scn HealthCheck</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN version          FORMAT a30    						HEADING 'Database Version' ENTMAP off
COLUMN DATE_TIME        FORMAT a50    						HEADING 'Date_Time'		   ENTMAP off
COLUMN indicator        FORMAT 999,999,999,999		        HEADING 'Indicator'        ENTMAP off

select
 version,
 to_char(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') DATE_TIME, 
 '<div align="left"><font color="#990000">' ||  ((((
  ((to_number(to_char(sysdate, 'YYYY')) - 1988) * 12 * 31 * 24 * 60 * 60) +
  ((to_number(to_char(sysdate, 'MM')) - 1) * 31 * 24 * 60 * 60) +
  (((to_number(to_char(sysdate, 'DD')) - 1)) * 24 * 60 * 60) +
  (to_number(to_char(sysdate, 'HH24')) * 60 * 60) +
  (to_number(to_char(sysdate, 'MI')) * 60) + 
  (to_number(to_char(sysdate, 'SS')))
 ) * (16 * 1024)) - dbms_flashback.get_system_change_number) 
 / (16 * 1024 * 60 * 60 * 24) 
 ) || '</font></div>' indicator 
  from v$instance;
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


set termout       ON
prompt 20% Collect Database Storage Information...... 
set termout       off 
-- +============================================================================+
-- |                                                                            |
-- |            <<<<<  Database Storage Information     >>>>>                   |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database Storage Information</u></b></font></center>

-- +----------------------------------------------------------------------------+
-- |                             - ASM DISK INFO -                              |
-- +----------------------------------------------------------------------------+
 
prompt <a name="asm_disk_info"></a> 
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Asm Disk Info</b></font><hr align="left" width="460">


CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               	FORMAT a40                   	 HEADING 'Disk_Name'         ENTMAP off
COLUMN path               	FORMAT a30                       HEADING 'Disk_Path'         ENTMAP off
COLUMN label                FORMAT a30                       HEADING 'Disk_label'        ENTMAP off
COLUMN disk_number          FORMAT 999,999,999,999,999       HEADING 'Disk_Number'       ENTMAP off
COLUMN group_number         FORMAT 999,999,999,999,999       HEADING 'Group_Number'      ENTMAP off
COLUMN failgroup            FORMAT a30                       HEADING 'Failgroup'         ENTMAP off
COLUMN header_status        FORMAT a30                       HEADING 'Header_Status'     ENTMAP off
COLUMN mount_status         FORMAT a30                       HEADING 'Mount_Status'      ENTMAP off
COLUMN state                FORMAT a30                       HEADING 'Disk_State'        ENTMAP off
COLUMN create_date          FORMAT a40                       HEADING 'Create_Date'       ENTMAP off
COLUMN mount_date           FORMAT a30                       HEADING 'Mount_date'             ENTMAP off
COLUMN total_mb             FORMAT 999,999,999,999,999   	 HEADING 'Total_MB'          ENTMAP off
COLUMN free_mb              FORMAT 999,999,999,999,999  	 HEADING 'Free_MB'           ENTMAP off


select '<div nowrap align="left"><font color="#336699"><b>' || name || '</b></font></div>'    name,
       '<div nowrap align="left"><font color="#336699"><b>' || path || '</b></font></div>'    path,
       label,
       disk_number,
       group_number,
       failgroup,
       DECODE(   header_status
            , 'MEMBER'
            , '<div align="center"><font color="darkgreen">' || header_status || '</font></div>'
            , 'PROVISIONED'
            , '<div align="center"><font color="#990000"><b>'   || header_status || '</b></font></div>'
            , '<div align="center"><font color="#E56600"><b>'   || header_status || '</b></font></div>')   header_status,
	   DECODE(   mount_status
            , 'CACHED'
            , '<div align="center"><font color="darkgreen">' || mount_status || '</font></div>'
            , 'MISSING'
            , '<div align="center"><font color="#990000"><b>'   || mount_status || '</b></font></div>'
            , '<div align="center"><font color="#E56600"><b>'   || mount_status || '</b></font></div>')   mount_status,
       DECODE(   state
            , 'NORMAL'
            , '<div align="center"><font color="darkgreen">' || state || '</font></div>'
            , 'UNKNOWN'
            , '<div align="center"><font color="#990000"><b>'   || state || '</b></font></div>'
            , '<div align="center"><font color="#E56600"><b>'   || state || '</b></font></div>')   state,
	   '<div nowrap align="right"><font color="#336699"><b>' || total_mb || '</b></font></div>'    total_mb,
	   '<div nowrap align="right"><font color="#E56600"><b>' || free_mb || '</b></font></div>'    free_mb,	   
       create_date,
       mount_date
  from v$asm_disk;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                              - ASM DISKGROUP INFO -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="asm_diskgroup_info"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Asm Diskgroup Info</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               	 	FORMAT a30                   	HEADING 'DiskGroup_Name'         ENTMAP off
COLUMN group_number          	FORMAT 999,999,999,999,999      HEADING 'DiskGroup_Number'       ENTMAP off
COLUMN type           		 	FORMAT a30                      HEADING 'DiskGroup_Type'      	 ENTMAP off
COLUMN state                 	FORMAT a30                      HEADING 'DiskGroup_State'    	 ENTMAP off
COLUMN compatibility         	FORMAT a30     				    HEADING 'Compatibility'          ENTMAP off
COLUMN AU_SIZE_MB  FORMAT a30   FORMAT 999,999,999,999,999      HEADING 'AU_SIZE_MB'             ENTMAP off
COLUMN total_mb              	FORMAT 999,999,999,999,999      HEADING 'Total_MB'          	 ENTMAP off
COLUMN free_mb              	FORMAT 999,999,999,999,999      HEADING 'Free_MB'           	 ENTMAP off

select  '<div align="left"><font color="#336699">' || name || '</font></div>'  name,
       group_number,    
	   '<div nowrap align="center"><font color="#E56600"><b>' || allocation_unit_size/1024/1024 || '</b></font></div>'    AU_SIZE_MB,
       type,
	   '<div nowrap align="right"><font color="#336699"><b>' || total_mb || '</b></font></div>'    total_mb,
	   '<div nowrap align="right"><font color="#E56600"><b>' || free_mb || '</b></font></div>'    free_mb,	
       DECODE(   state
            , 'CONNECTED'
            , '<div align="center"><font color="darkgreen">' || state || '</font></div>'
            , 'UNKNOWN'
            , '<div align="center"><font color="#990000"><b>'   || state || '</b></font></div>'
            , '<div align="center"><font color="#E56600"><b>'   || state || '</b></font></div>')   state,
       compatibility
  from v$asm_diskgroup;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespaces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name        FORMAT a40                  HEADING 'Tbs.Name'   		ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext.Mgt.'         ENTMAP off
COLUMN segment_mgt 	FORMAT a9                   HEADING 'Seg.Mgt.'         ENTMAP off
COLUMN allocation_type 	FORMAT a16			   	HEADING 'Alloca.Type'   ENTMAP off
COLUMN initial_extent  	FORMAT 999,999,999,999,999			   HEADING 'In.Ex.(Kb)'          ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'TBS_Size(MB)'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'UsedSize (MB)'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'FreeSize (MB)'   ENTMAP off
COLUMN pct_used                                HEADING 'PctUsed(%)'         ENTMAP off

BREAK ON report
COMPUTE count LABEL '<font color="#990000"><b>Total: </b></font>' OF name ON report

SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name || '</font></b>'                               name
  , d.contents                                          type
  , d.extent_management                                 extent_mgt
  , d.segment_space_management                          segment_mgt
  , d.ALLOCATION_TYPE									allocation_type
  , d.initial_extent/1024									initial_extent
  , NVL(a.bytes/ 1024 / 1024, 0)                                     ts_size
  , NVL(a.bytes/ 1024 / 1024 - NVL(f.bytes/ 1024 / 1024, 0), 0)                   used
  , NVL(f.bytes/ 1024 / 1024, 0)                                     free
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM 
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_data_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes) bytes
      from dba_free_space
      group by tablespace_name
    ) f
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = f.tablespace_name(+)
  AND NOT (
    d.extent_management like 'LOCAL'
    AND
    d.contents like 'TEMPORARY'
  )
UNION ALL 
SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name  || '</font></b>'                              name
  , d.contents                                   type
  , d.extent_management                          extent_mgt
  , d.segment_space_management                   segment_mgt
  , d.ALLOCATION_TYPE									allocation_type
  , d.initial_extent/1024									initial_extent
  , NVL(a.bytes/ 1024 / 1024, 0)                              ts_size
  , NVL(t.bytes/ 1024 / 1024, 0)                              used
  , NVL(a.bytes/ 1024 / 1024 - NVL(t.bytes/ 1024 / 1024,0), 0)             free
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_temp_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes_cached) bytes
      from v$temp_extent_pool
      group by tablespace_name
    ) t
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = t.tablespace_name(+)
  AND d.extent_management like 'LOCAL'
  AND d.contents like 'TEMPORARY'
ORDER BY pct_used ASC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - DATA FILES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="data_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN ts#                                   				HEADING 'Ts#'  ENTMAP off
COLUMN file#                                 				HEADING 'File#'  ENTMAP off
COLUMN status                                				HEADING 'Status'  ENTMAP off
COLUMN enabled          	FORMAT a30                      HEADING 'Enabled'  ENTMAP off
COLUMN tablespace                                   		HEADING 'Tablespace'  ENTMAP off
COLUMN filename                                     		HEADING 'Filename'                      ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999,999   		HEADING 'FileSize_MB'                     ENTMAP off
COLUMN autoextensible                               		HEADING 'Autoext.'                ENTMAP off
COLUMN increment_by    FORMAT 999,999,999,999,999   		HEADING 'Next_MB'                          ENTMAP off
COLUMN maxbytes        FORMAT 999,999,999,999,999   		HEADING 'Max_MB'                           ENTMAP off

BREAK ON tablespace ON report

SELECT v.file# file#,v.ts# ts#
  , '<b><font color="#336699">' || d.file_name  || '</font></b>'                              file_name
  , d.bytes/1024/1024                filesize
  , DECODE(   v.status
            , 'ONLINE'
            , '<div align="center"><b><font color="darkgreen">' || v.status || '</font></b></div>'
            , 'RECOVER'
            , '<div align="center"><b><font color="#E53333">'   || v.status || '</font></b></div>'
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || v.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || v.status || '</font></b></div>'
    )                                                                                       status
  ,v.enabled enabled,
  /*+ ordered */
    '<font color="#336699"><b>' || d.tablespace_name  || '</b></font>'  tablespace
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by/1024/1024  * e.value                                            increment_by
  , d.maxbytes/1024/1024                                                           maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
  ORDER BY
    2,
	1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                            - TEMP FILES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="temp_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Temp File</b></font><hr align="left" width="460">


CLEAR COLUMNS BREAKS COMPUTES

COLUMN file_id                                 				HEADING 'File_id'  ENTMAP off
COLUMN status                                				HEADING 'File_status'  ENTMAP off
COLUMN tablespace                                   		HEADING 'TablespaceName'  ENTMAP off
COLUMN filename                                     		HEADING 'Filename'                      ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999,999   		HEADING 'FileSize_MB'                     ENTMAP off
COLUMN autoextensible                               		HEADING 'Autoex.'                ENTMAP off
COLUMN increment_by    FORMAT 999,999,999,999,999   		HEADING 'Next_MB'                          ENTMAP off
COLUMN maxbytes        FORMAT 999,999,999,999,999   		HEADING 'Max_MB'                           ENTMAP off

BREAK ON tablespace

SELECT  d.file_id
   ,'<b><font color="#336699">' || d.file_name  || '</font></b>'       file_name
   ,'<font color="#336699"><b>' || d.tablespace_name || '</b></font>'   tablespace 
    , DECODE(   d.status
            , 'ONLINE'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>'
            , 'RECOVER'
            , '<div align="center"><b><font color="#E53333">'   || d.status || '</font></b></div>'
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || d.status || '</font></b></div>'
    )                                                                                       status
  , d.bytes/1024/1024                                                              filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by/1024/1024  * e.value                                            increment_by
  , d.maxbytes/1024/1024                                                           maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e 
ORDER BY
    1
  , 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                            - Data FILES Header -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="data_files_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Files Header</b></font><hr align="left" width="460">


CLEAR COLUMNS BREAKS COMPUTES

COLUMN file#                                 					HEADING 'File#'  ENTMAP off
COLUMN ts#                                   					HEADING 'Ts#'  ENTMAP off
COLUMN status                                					HEADING 'Status'  ENTMAP off
COLUMN TABLESPACE_NAME                                   		HEADING 'Tablespace'  ENTMAP off
COLUMN ERROR                                     				HEADING 'Error'                      ENTMAP off
COLUMN CREATE_TIME        	FORMAT 999,999,999,999,999   		HEADING 'Create_Time'                     ENTMAP off
COLUMN checkpoint_change# 	FORMAT 999,999,999,999,999          HEADING 'Ckpt_Change#'  ENTMAP off
COLUMN recover          	FORMAT a30                     		HEADING 'Recover'                ENTMAP off
COLUMN FUZZY                FORMAT a20               			HEADING 'FUZZY'                ENTMAP off
COLUMN SCN    				FORMAT 999,999,999,999,999   		HEADING 'SCN'                          ENTMAP off
COLUMN RESETLOGS_SCN        FORMAT 999,999,999,999,999   		HEADING 'RESETLOGS_SCN'                           ENTMAP off

BREAK ON report

select file#,
       ts#,
       TABLESPACE_NAME,
   	   DECODE(   status
            , 'ONLINE'
            , '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'RECOVER'
            , '<div align="center"><b><font color="#E53333">'   || status || '</font></b></div>'
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>'
   		 )                                                                                       status
	   ,ERROR,
       FORMAT
	   ,DECODE(   recover
            , 'NO'
            , '<div align="center"><font color="darkgreen">'  || recover || '</font></div>'
            , '<div align="center"><font color="red">'  || recover || '</font></div>') recover
	   ,FUZZY
       ,CREATION_TIME      CREATE_TIME,checkpoint_change# checkpoint_change#
	   ,'<b><font color="#64451D">' || checkpoint_change#   || '</font></b>'       SCN
       ,'<b><font color="#64451D">' || RESETLOGS_CHANGE#  || '</font></b>'         RESETLOGS_SCN
  from v$datafile_header
 order by 1, 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - DATABASE GROWTH -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="database_growth"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Growth</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN month        FORMAT a75                  HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999  HEADING 'Growth (MB)'

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF growth ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || TO_CHAR(creation_time, 'RRRR-MM') || '</b></font></div>' month
  , SUM(bytes/1024/1024)                        growth
FROM     sys.v_$datafile
-- where creation_time > to_date('2010-01','RRRR-MM')
GROUP BY creation_time
ORDER BY 1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                        - OWNER DATA SIZE  -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="owner_data_size"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Owner Data Size</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size(MB)'         ENTMAP off

BREAK ON report ON owner

select   
    	'<font color="#336699"><b>'  || owner           || '</b></font>' owner
		,trunc(sum(bytes)/1024/1024) bytes 
from 
dba_segments 
where &str_owner
group by owner 
order by 2 desc;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                       - OWNER TO TABLESPACE -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="owner_to_tablespace"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Owner to Tablespace</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name  FORMAT a75                  HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_type     FORMAT a75                  HEADING 'Segment Type'     ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size (MB)'  ENTMAP off
COLUMN seg_count        FORMAT 999,999,999,999      HEADING 'Segment Count'    ENTMAP off

break on report on owner

SELECT
    '<font color="#336699"><b>'  || owner           || '</b></font>' owner
  , '<div align="right">'        || tablespace_name || '</div>'      tablespace_name
  , '<div align="right">'        || segment_type    || '</div>'      segment_type
  , sum(bytes/1024/1024)                                                       bytes
  , count(*)                                                         seg_count
FROM
    dba_segments
	where &str_owner
GROUP BY
    owner
  , tablespace_name
  , segment_type
ORDER BY
    owner
  , tablespace_name
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                       - UNDO RETENTION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_retention_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Retention Parameters</b></font><hr align="left" width="460">

prompt <b>undo_retention is specified in minutes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'undo_retention' THEN '<div nowrap align="right">' || TO_CHAR(TO_NUMBER(p.value), '999,999,999,999,999') ||  '</div>'
     ELSE
         '<div nowrap align="right">' || p.value || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name LIKE 'undo%'
ORDER BY
    i.instance_name
  , p.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                            - UNDO SEGMENTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Segments</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a75              HEADING 'Instance Name'      ENTMAP off
COLUMN tablespace    FORMAT a85              HEADING 'Tablspace'          ENTMAP off
COLUMN roll_name                             HEADING 'UNDO Segment Name'  ENTMAP off
COLUMN in_extents                            HEADING 'Init/Next Extents'  ENTMAP off
COLUMN m_extents                             HEADING 'Min/Max Extents'    ENTMAP off
COLUMN status                                HEADING 'Status'             ENTMAP off
COLUMN wraps         FORMAT 999,999,999      HEADING 'Wraps'              ENTMAP off
COLUMN shrinks       FORMAT 999,999,999      HEADING 'Shrinks'            ENTMAP off
COLUMN opt           FORMAT 999,999,999,999  HEADING 'Opt. Size'          ENTMAP off
COLUMN bytes         FORMAT 999,999,999,999  HEADING 'Bytes_KB'              ENTMAP off
COLUMN extents       FORMAT 999,999,999      HEADING 'Extents'            ENTMAP off

CLEAR COMPUTES BREAKS

BREAK ON report ON instance_name ON tablespace
-- COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF bytes extents shrinks wraps ON report

SELECT
    '<div nowrap><font color="#336699"><b>' ||  NVL(i.instance_name, '<br>')     || '</b></font></div>'  instance_name
  , '<div nowrap><font color="#336699"><b>' ||  a.tablespace_name                || '</b></font></div>'  tablespace
  , '<div nowrap>'                          ||  a.owner || '.' || a.segment_name || '</div>'             roll_name
  , '<div align="right">'     ||
    TO_CHAR(a.initial_extent) || ' / ' ||
    TO_CHAR(a.next_extent)    ||
    '</div>'                                                                in_extents
  , '<div align="right">'     ||
    TO_CHAR(a.min_extents)    || ' / ' ||
    TO_CHAR(a.max_extents)    ||
    '</div>'                                                                m_extents
  , DECODE(   a.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || a.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || a.status || '</font></b></div>') status
  , b.bytes/1024                              bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
    dba_rollback_segs a
  , dba_segments b
  , v$rollname c
  , v$rollstat d
  , gv$parameter p
  , gv$instance  i
WHERE
       a.segment_name  = b.segment_name
  AND  a.segment_name  = c.name (+)
  AND  c.usn           = d.usn (+)
  AND  p.name (+)      = 'undo_tablespace'
  AND  p.value (+)     = a.tablespace_name
  AND  p.inst_id       = i.inst_id (+)
ORDER BY
    a.tablespace_name
  , a.segment_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


set termout       ON
prompt 40% Collect Database Objects Information...... 
set termout       off 
-- +============================================================================+
-- |                                                                            |
-- |            <<<<<  Database  Objects Information     >>>>>                  |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database  Objects Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                             - USER ACCOUNTS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="user_accounts"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>User Accounts</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username              FORMAT a40    HEAD 'Username'        ENTMAP off
COLUMN account_status        FORMAT a75    HEAD 'Account Status'  ENTMAP off
COLUMN expiry_date           FORMAT a75    HEAD 'Expire Date'     ENTMAP off
COLUMN default_tablespace    FORMAT a75    HEAD 'Default Tbs.'    ENTMAP off
COLUMN temporary_tablespace  FORMAT a75    HEAD 'Temp Tbs.'       ENTMAP off
COLUMN created               FORMAT a75    HEAD 'Created On'      ENTMAP off
COLUMN profile               FORMAT a75    HEAD 'Profile'         ENTMAP off


BREAK ON report ON username
COMPUTE count LABEL '<font color="#990000"><b>Total: </b></font>' OF username ON report


SELECT distinct
    '<b><font color="#336699">' || a.username || '</font></b>'                                            username
  , DECODE(   a.account_status
            , 'OPEN'
            , '<div align="left"><b><font color="darkgreen">' || a.account_status || '</font></b></div>'
            , '<div align="left"><b><font color="#663300">'   || a.account_status || '</font></b></div>') account_status
  , '<div nowrap align="right">' || NVL(TO_CHAR(a.expiry_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'           expiry_date
  , a.default_tablespace                                                                                  default_tablespace
  , a.temporary_tablespace                                                                                temporary_tablespace
  , '<div nowrap align="right">' || TO_CHAR(a.created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'               created
  , a.profile                                        profile
FROM
    dba_users       a
  , v$pwfile_users  p
WHERE
    p.username (+) = a.username 
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - USERS WITH DBA PRIVILEGES -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_dba_privileges"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With DBA Privileges</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN grantee        FORMAT a70   HEADING 'Grantee'         ENTMAP off
COLUMN granted_role   FORMAT a35   HEADING 'Granted Role'    ENTMAP off
COLUMN admin_option   FORMAT a75   HEADING 'Admin. Option?'  ENTMAP off
COLUMN default_role   FORMAT a75   HEADING 'Default Role?'   ENTMAP off

SELECT
    '<b><font color="#336699">' || grantee       || '</font></b>'  grantee
  , '<div align="center">'      || granted_role  || '</div>'  granted_role
  , DECODE(   admin_option
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || admin_option || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || admin_option || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || admin_option || '</b></font></div>')   admin_option
  , DECODE(   default_role
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || default_role || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || default_role || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || default_role || '</b></font></div>')   default_role
FROM
    dba_role_privs
WHERE
    granted_role = 'DBA'
ORDER BY
    grantee
  , granted_role;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                          - User Priv           -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="User_Priv"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>User Priv</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN GRANTEE         	    FORMAT a30                   	HEADING 'GRANTEE'              ENTMAP off
COLUMN PRIV   				FORMAT a100        			 	HEADING 'PRIV'     	 ENTMAP off
COLUMN PRIVTYPE   			FORMAT a30        				HEADING 'PRIVTYPE'   	 	 ENTMAP off

BREAK ON report ON GRANTEE

select GRANTEE,priv,
  DECODE(   PRIVTYPE
            , 'ROLE'
            , '<div align="center"><font color="darkgreen"><b>' || PRIVTYPE || '</b></font></div>'
            , 'SYS PRIV'
            , '<div align="center"><font color="#990000">'   || PRIVTYPE || '</font></div>'
            , '<div align="center"><font color="#663300">'   || PRIVTYPE || '</font></div>')   PRIVTYPE
  from (select r.grantee, r.granted_role priv, 'ROLE' privtype
          from dba_role_privs r, dba_users u
         where r.grantee = u.username
        union all
        select s.grantee, s.privilege priv, 'SYS PRIV' privtype
          from dba_sys_privs s, dba_users u
         where s.grantee = u.username)
 order by grantee, privtype, priv;
 
   
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                                 - ROLES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="roles"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Roles</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN role             FORMAT a70    HEAD 'Role Name'       ENTMAP off
COLUMN grantee          FORMAT a35    HEAD 'Grantee'         ENTMAP off
COLUMN admin_option     FORMAT a75    HEAD 'Admin Option?'   ENTMAP off
COLUMN default_role     FORMAT a75    HEAD 'Default Role?'   ENTMAP off

BREAK ON report ON role

SELECT
   '<b><font color="#336699">' ||  b.role         || '</font></b>'          role
  , a.grantee                                                               grantee
  , DECODE(   a.admin_option
            , null
            , '<br>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || a.admin_option || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || a.admin_option || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || a.admin_option || '</b></font></div>')   admin_option
  , DECODE(   a.default_role
            , null
            , '<br>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || a.default_role || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || a.default_role || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || a.default_role || '</b></font></div>')   default_role
FROM
    dba_role_privs  a
  , dba_roles       b
WHERE
    granted_role(+) = b.role
ORDER BY
    b.role
  , a.grantee;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - DEFAULT PASSWORDS -                             |

-- +----------------------------------------------------------------------------+

prompt <a name="default_passwords"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Default Passwords</b></font><hr align="left" width="460">

prompt <b>User(s) with default password</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                      HEADING 'Username'        ENTMAP off
COLUMN account_status   FORMAT a75   HEADING 'Account Status'  ENTMAP off

SELECT
    '<b><font color="#336699">' || username        || '</font></b>'        username
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="left"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="left"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM dba_users
WHERE password IN (
    'E066D214D5421CCC'   -- dbsnmp
  , '24ABAB8B06281B4C'   -- ctxsys
  , '72979A94BAD2AF80'   -- mdsys
  , 'C252E8FA117AF049'   -- odm
  , 'A7A32CD03D3CE8D5'   -- odm_mtr
  , '88A2B2C183431F00'   -- ordplugins
  , '7EFA02EC7EA6B86F'   -- ordsys
  , '4A3BA55E08595C81'   -- outln
  , 'F894844C34402B67'   -- scott
  , '3F9FBD883D787341'   -- wk_proxy
  , '79DF7A1BD138CF11'   -- wk_sys
  , '7C9BA362F8314299'   -- wmsys
  , '88D8364765FCE6AF'   -- xdb
  , 'F9DA8977092B7B81'   -- tracesvr
  , '9300C0977D7DC75E'   -- oas_public
  , 'A97282CE3D94E29E'   -- websys
  , 'AC9700FD3F1410EB'   -- lbacsys
  , 'E7B5D92911C831E1'   -- rman
  , 'AC98877DE1297365'   -- perfstat
  , 'D4C5016086B2DC6A'   -- sys
  , 'D4DF7931AB130E37')  -- system
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                              - DB LINKS -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="db_links"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>DB Links</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner        FORMAT a75    HEADING 'Owner'           ENTMAP off
COLUMN db_link      FORMAT a75    HEADING 'DB Link Name'    ENTMAP off
COLUMN username     FORMAT a35               HEADING 'Username'        ENTMAP off
COLUMN host         FORMAT a25               HEADING 'Host'            ENTMAP off

COLUMN created      FORMAT a75    HEADING 'Created'         ENTMAP off

BREAK ON owner

SELECT
    '<b><font color="#336699">' || owner || '</font></b>'  owner
  , db_link
  , username
  , host
  , '<div nowrap align="right">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>' created
FROM dba_db_links
ORDER BY owner, db_link;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                 - Scheduler Jobs -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="scheduler_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Scheduler Jobs</b></font><hr align="left" width="460">

prompt <tr><th align="left"><b>Jobs:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job_id     FORMAT a75             HEADING 'Job ID'           ENTMAP off
COLUMN username   FORMAT a75             HEADING 'User'             ENTMAP off
COLUMN what       FORMAT a175            HEADING 'What'             ENTMAP off
COLUMN next_date  FORMAT a110            HEADING 'Next Run Date'    ENTMAP off
COLUMN interval   FORMAT a75             HEADING 'Interval'         ENTMAP off
COLUMN last_date  FORMAT a110            HEADING 'Last Run Date'    ENTMAP off
COLUMN failures   FORMAT a75             HEADING 'Failures'         ENTMAP off
COLUMN broken     FORMAT a75             HEADING 'Broken?'          ENTMAP off

BREAK ON User ON username

SELECT
    DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || job || '</div></font></b>'
            , '<b><font color="#336699"><div align="center">' || job || '</div></font></b>')    job_id
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || log_user || '</font></b>'
            , log_user )    username
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || what || '</font></b>'
            , what )        what
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')      next_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || interval || '</font></b>'
            , interval )    interval
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')    last_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || NVL(failures, 0) || '</div></font></b>'
            , '<div align="center">'                          || NVL(failures, 0) || '</div>')    failures
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || broken || '</div></font></b>'
            , '<div align="center">'                          || broken || '</div>')      broken
FROM
    dba_jobs
ORDER BY
    job;
	
prompt <tr><th align="left"><b></b></th><tr>
prompt <tr><th align="left"><b>Scheduler:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job_name     	FORMAT a30             HEADING 'job_name'           ENTMAP off
COLUMN owner   			FORMAT a20             HEADING 'owner'             ENTMAP off
COLUMN next_run_date 	FORMAT a36            HEADING 'Next Run Date'    ENTMAP off
COLUMN start_date   	FORMAT a36             HEADING 'Start date'         ENTMAP off
COLUMN last_start_date  FORMAT a36            HEADING 'Last Run Date'    ENTMAP off
COLUMN enabled   		FORMAT a10             HEADING 'Enabled?'         ENTMAP off
COLUMN state     		FORMAT a20             HEADING 'State'          ENTMAP off

BREAK ON owner

select 
  '<div align="left"><font color="#336699"><b>' || job_name || '</b></font></div>' job_name,
       owner,
       program_name,
       job_action,
       to_char(start_date, 'yyyy-mm-dd hh24:mi:ss') job_first_start_date,
       to_char(next_run_date, 'yyyy-mm-dd hh24:mi:ss') job_next_run_date,
       to_char(last_start_date, 'yyyy-mm-dd hh24:mi:ss') job_last_start_date
 	  , DECODE(   enabled
            , 'TRUE'
            , '<div align="center"><font color="darkgreen">' || enabled || '</font></div>'
            , 'FALSE'
            , '<div align="center"><font color="#990000"><b>'   || enabled || '<b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || enabled || '<b></font></div>')   enabled
       ,(CASE state
         WHEN 'RUNNING'  THEN '<div align="center"><b><font color="darkgreen">'  || state || '</font></b></div>'
		 WHEN 'DISABLED'  THEN '<div align="center"><b><font color="#990000">'  || state || '</font></b></div>'
         WHEN 'BROKEN'   THEN '<div align="center"><b><font color="#990000">'   || state || '</font></b></div>'
		 WHEN 'FAILED'   THEN '<div align="center"><b><font color="#990000">'   || state || '</font></b></div>'
     ELSE
         '<div align="center"><b><font color="#EE33EE">'   || state || '</font></b></div>'
     END)    state
  from DBA_SCHEDULER_JOBS;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                            - OBJECT SUMMARY -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="object_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Object Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a20               HEADING 'Owner'           ENTMAP off
COLUMN object_type     FORMAT a40               HEADING 'Object Type'     ENTMAP off
COLUMN obj_count       FORMAT 999,999,999,999   HEADING 'Object Count'    ENTMAP off

BREAK ON report ON owner

-- compute sum label ""               of obj_count on owner
-- compute sum label '<font color="#990000"><b>Grand Total: </b></font>' of obj_count on report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF obj_count ON report

SELECT
  '<div align="left"><font color="#336699"><b>' || owner || '</b></font></div>' owner
  , object_type                                            object_type
  , count(*)                                               obj_count
FROM
    dba_objects
	where &str_owner
GROUP BY
    owner
  , object_type
ORDER BY
    owner
  , object_type;
  

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - SEGMENT SUMMARY -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="segment_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Segment Summary</b></font><hr align="left" width="460">

  
CLEAR COLUMNS BREAKS COMPUTES
COLUMN bytes           FORMAT 999999999.99               HEADING 'Size_MB'           ENTMAP off

select SEGMENT_TYPE, sum(bytes)/1024/1024 bytes
  from dba_segments
 group by SEGMENT_TYPE;
 
CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a50                    HEADING 'Owner'             ENTMAP off
COLUMN segment_type    FORMAT a25                    HEADING 'Segment Type'      ENTMAP off
COLUMN seg_count       FORMAT 999,999,999,999        HEADING 'Segment Count'     ENTMAP off
COLUMN bytes           FORMAT 999,999,999,999,999    HEADING 'Size (in MB)'   ENTMAP off

BREAK ON report ON owner SKIP 2
-- COMPUTE sum LABEL ""                                                  OF seg_count bytes ON owner
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF seg_count bytes ON report

SELECT
    '<b><font color="#336699">' || owner || '</font></b>'  owner
  , segment_type        segment_type
  , count(*)            seg_count
  , sum(bytes/1024/1024)          bytes
FROM
    dba_segments
	where &str_owner
GROUP BY
    owner
  , segment_type
ORDER BY
    owner
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                          - INVALID OBJECTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="invalid_objects"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Invalid Objects</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a40         HEADING 'Owner'         ENTMAP off
COLUMN object_name     FORMAT a40         HEADING 'Object Name'   ENTMAP off
COLUMN object_type     FORMAT a30         HEADING 'Object Type'   ENTMAP off
COLUMN status          FORMAT a75         HEADING 'Status'        ENTMAP off

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Grand Total: </b></font>' OF object_name ON report

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , object_name
  , object_type
  , DECODE(   status
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || status || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || status || '</b></font></div>' ) status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY
    owner
  , object_name;

prompt <b>Invalid Index:</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a40         HEADING 'Owner'         ENTMAP off
COLUMN index_name     FORMAT a60         HEADING 'IndexName'   ENTMAP off
COLUMN table_name     FORMAT a40         HEADING 'TableName'   ENTMAP off
COLUMN tablespace_name     FORMAT a60         HEADING 'TbsName'   ENTMAP off
COLUMN status          FORMAT a75         HEADING 'Status'        ENTMAP off

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Grand Total: </b></font>' OF index_name ON report

select   '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
	,index_name
	,table_name
	,tablespace_name
	, DECODE(   status
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || status || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || status || '</b></font></div>' ) status
 From dba_indexes 
Where status not in ('VALID','N/A');

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                     - PROCEDURAL OBJECT ERRORS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="procedural_object_errors"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Procedural Object Errors</b></font><hr align="left" width="460">

prompt <b>All records from DBA_ERRORS</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                FORMAT a85      HEAD 'Schema'        ENTMAP off
COLUMN name                 FORMAT a30      HEAD 'Object Name'   ENTMAP off
COLUMN type                 FORMAT a15      HEAD 'Object Type'   ENTMAP off
COLUMN sequence             FORMAT 999,999  HEAD 'Sequence'      ENTMAP off
COLUMN line                 FORMAT 999,999  HEAD 'Line'          ENTMAP off
COLUMN position             FORMAT 999,999  HEAD 'Position'      ENTMAP off
COLUMN text                                 HEAD 'Text'          ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , name
  , type
  , sequence
  , line
  , position
  , text
FROM
    dba_errors
ORDER BY
    1
  , 2
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                - collect analyazed tables and indexes info     -           |
-- +----------------------------------------------------------------------------+

prompt <a name="collect_analyazed_info"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Collect Analyazed Tables and Indexes Info</b></font><hr align="left" width="460">

prompt <tr><th align="left"><b>collect analyazed tables info,num_rows gt 100w:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a50                    HEADING 'Owner'             ENTMAP off
COLUMN TABLE_NAME      FORMAT a50        			 HEADING 'TABLE_NAME'     	 ENTMAP off
COLUMN num_rows        FORMAT 9999999999999        	 HEADING 'Num_Rows'     	 ENTMAP off
COLUMN LAST_ANALYZED   FORMAT a100        			 HEADING 'LAST_ANALYZED'   	 ENTMAP off

BREAK ON owner

select owner, table_name,num_rows 
  ,'<div align="left"><font color="#336699"><b>' || LAST_ANALYZED || '</b></font></div>' LAST_ANALYZED
  from dba_tables
 where &str_owner
   and LAST_ANALYZED is not null
   and num_rows > 1000000
   order by num_rows desc;

prompt <tr><th align="left"><b>collect analyazed indexes info,num_rows gt 100w:</b></th><tr>
prompt <tr><th align="left"><b></b></th><tr>   

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a50                    HEADING 'Owner'             ENTMAP off
COLUMN index_name      FORMAT a50        			 HEADING 'Index_name'     	 ENTMAP off
COLUMN num_rows        FORMAT 9999999999999        	 HEADING 'Num_Rows'     	 ENTMAP off
COLUMN LAST_ANALYZED   FORMAT a100        			 HEADING 'LAST_ANALYZED'   	 ENTMAP off

BREAK ON owner

select owner, index_name,num_rows 
  ,'<div align="left"><font color="#336699"><b>' || LAST_ANALYZED || '</b></font></div>' LAST_ANALYZED
  from dba_indexes
 where &str_owner
   and LAST_ANALYZED is not null
   and num_rows > 1000000
   order by num_rows desc;
    
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                          - Public Synonym  -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="public_synonym"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Public Synonym</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN TABLE_OWNER     FORMAT a30       			 HEADING 'TABLE_OWNER'    	 ENTMAP off
COLUMN SYNONYM_NAME    FORMAT a50                    HEADING 'SYNONYM_NAME'      ENTMAP off
COLUMN TABLE_NAME      FORMAT a50        			 HEADING 'TABLE_NAME'     	 ENTMAP off
COLUMN DB_LINK         FORMAT a100        			 HEADING 'DB_LINK'   		 ENTMAP off

BREAK ON report ON TABLE_OWNER

select 
  '<div align="left"><font color="#336699"><b>' || TABLE_OWNER || '</b></font></div>' TABLE_OWNER
  , SYNONYM_NAME
  , TABLE_NAME
  , DB_LINK
  from dba_synonyms
 where &tab_owner
   and owner = 'PUBLIC'
 order by owner;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                          -  Trigger Check  -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="trigger_check"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Trigger Check</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         	   FORMAT a50         HEADING 'Owner'           ENTMAP off
COLUMN ObjectName          FORMAT a50         HEADING 'Object_Name'     ENTMAP off
COLUMN created             FORMAT a75    	  HEAD 'Created On'         ENTMAP off
COLUMN last_ddl_time       FORMAT a75    	  HEAD 'Last_DDL_Time'      ENTMAP off

BREAK ON report ON owner
  
SELECT owner,
       '<div nowrap align="left"><font color="#336699"><b>' || object_name || '</b></font></div>' "ObjectName",
       created,
       last_ddl_time,
       DECODE(status,
              'VALID',
              '<div align="center"><b><font color="darkgreen">' || status ||
              '</font></b></div>',
              '<div align="center"><b><font color="#663300">' || status ||
              '</font></b></div>') status
  FROM DBA_OBJECTS
 WHERE OBJECT_TYPE = 'TRIGGER'
   and &str_owner;

 
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - disabled constraints       -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="disabled_constraints"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Disabled Constraints</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         	 FORMAT a20                   	HEADING 'Owner'              ENTMAP off
COLUMN CONSTRAINT_NAME   FORMAT a80        			 	HEADING 'CONSTRAINT_NAME'     	 ENTMAP off
COLUMN CONSTRAINT_TYPE   FORMAT a30        				HEADING 'CONSTRAINT_TYPE'   	 ENTMAP off
COLUMN TABLE_NAME        FORMAT a30				        HEADING 'TABLE_NAME'   	 ENTMAP off
COLUMN STATUS        	 FORMAT a30				        HEADING 'STATUS'   	 ENTMAP off

select owner , 
  '<div align="left"><font color="#336699"><b>' || CONSTRAINT_NAME || '</b> </font> </div>' CONSTRAINT_NAME
 , CONSTRAINT_TYPE, TABLE_NAME,STATUS
  from dba_constraints
 where STATUS = 'DISABLED';

   
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - Indexes Foreign Key -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="Indexes_Foreign_Key"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Indexes Foreign Key</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a30         HEADING 'Owner'         ENTMAP off
COLUMN Status     	   FORMAT a50         HEADING 'Status'   ENTMAP off
COLUMN table_name      FORMAT a50         HEADING 'Table_Name'   ENTMAP off
COLUMN index_columns   FORMAT a55         HEADING 'Index_Columns'        ENTMAP off

select a.owner,decode(b.table_name, NULL, 'NOINDEX', 'INDEXED') Status,a.table_name,a.columns,b.columns as index_columns
from
(select a.owner,a.table_name,a.constraint_name,
   max(decode(position,1,column_name,NULL)) ||
   max(decode(position,2,', '|| column_name,NULL)) ||
   max(decode(position,3,', '|| column_name,NULL)) ||
   max(decode(position,4,', '|| column_name,NULL)) ||
   max(decode(position,5,', '|| column_name,NULL)) ||
   max(decode(position,6,', '|| column_name,NULL))  columns
      from dba_cons_columns a,  dba_constraints b
      where a.constraint_name = b.constraint_name  and a.owner=b.owner and b.constraint_type = 'R'
      group by a.table_name,
               a.constraint_name,
               a.owner) a,
    (select index_owner, table_name table_name, index_name,
  max(decode(column_position,1,column_name, NULL)) ||
  max(decode(column_position,2,', '|| column_name,NULL)) ||
  max(decode(column_position,3,', '|| column_name,NULL)) ||
  max(decode(column_position,4,', '|| column_name,NULL)) ||
  max(decode(column_position,5,', '|| column_name,NULL)) ||
  max(decode(column_position,6,', '|| column_name,NULL))  columns
  from dba_ind_columns  group by table_name,
   index_name,
   index_owner) b
where a.table_name = b.table_name(+) and a.owner=b.index_owner(+)
and a.owner not in ('SYS','SYSTEM','SCOTT','OUTLN','APPQOSSYS','DBSNMP','SYSMAN','ORDSYS','OLAPSYS','MDSYS','EXFSYS','XDB','CTXSYS','DMSYS','WMSYS')
and b.columns(+) like a.columns || '%'
order by Status,a.owner,a.table_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                          - Tables With No Logging          -               |
-- +----------------------------------------------------------------------------+

prompt <a name="Tables_With_No_Logging"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tables With No Logging</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         	    FORMAT a30                   	HEADING 'Owner'              ENTMAP off
COLUMN table_name   		FORMAT a80        			 	HEADING 'Table_Name'     	 ENTMAP off
COLUMN logging   			FORMAT a20        				HEADING 'Logging'   	 	 ENTMAP off
COLUMN tablespace_name      FORMAT a40				        HEADING 'Tablespace_Name'    ENTMAP off

BREAK ON owner
select owner,tablespace_name
,'<div align="left"><font color="#336699"><b>' || table_name || '</b></font></div>' table_name
,'<div align="left"><font color="#E56600"><b>' || logging || '</b></font></div>' logging
  from dba_tables
 where logging = 'NO'
   and &str_owner
 order by owner;
   
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                           - LOB SEGMENTS -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_lob_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>LOB Segments</b></font><hr align="left" width="460">

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a85        HEADING 'Owner'              ENTMAP off
COLUMN table_name         FORMAT a75        HEADING 'Table Name'         ENTMAP off
COLUMN column_name        FORMAT a75        HEADING 'Column Name'        ENTMAP off
COLUMN segment_name       FORMAT a125       HEADING 'LOB Segment Name'   ENTMAP off
COLUMN tablespace_name    FORMAT a75        HEADING 'Tablespace Name'    ENTMAP off
COLUMN lob_segment_bytes  FORMAT a75        HEADING 'Segment_Size_KB'       ENTMAP off
COLUMN index_name         FORMAT a125       HEADING 'LOB Index Name'     ENTMAP off
COLUMN in_row             FORMAT a75        HEADING 'In Row?'            ENTMAP off

BREAK ON report ON owner ON table_name

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || t.owner || '</b></font></div>'    owner
  , '<div nowrap>' || t.table_name        || '</div>'       table_name
  , '<div nowrap>' || t.column_name       || '</div>'       column_name
  , '<div nowrap>' || t.segment_name      || '</div>'       segment_name
  , '<div nowrap>' || s.tablespace_name   || '</div>'       tablespace_name
  , '<div nowrap align="right">' || TO_CHAR(s.bytes/1024, '999,999,999,999,999') || '</div>'  lob_segment_bytes
  , '<div nowrap>' || t.index_name        || '</div>'       index_name
  , DECODE(   t.in_row
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || t.in_row || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || t.in_row || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || t.in_row || '</b></font></div>')   in_row
FROM
    dba_lobs     t
  , dba_segments s
WHERE
      t.owner = s.owner
  AND t.segment_name = s.segment_name
  AND &t_str_owner
ORDER BY
    t.owner
  , t.table_name
  , t.column_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |             - USERS WITH DEFAULT TABLESPACE - (SYSTEM) -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_default_tablespace_defined_as_system"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With Default Tablespace - (SYSTEM)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                 FORMAT a75    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a125   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a125   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a75    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a75    HEADING 'Account Status'          ENTMAP off

SELECT
    '<font color="#336699"><b>' || username             || '</font></b>'                  username
  , '<div align="left">'        || default_tablespace   || '</div>'                       default_tablespace
  , '<div align="left">'        || temporary_tablespace || '</div>'                       temporary_tablespace
  , '<div align="right">'       || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  created
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="center"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM
    dba_users
WHERE
    default_tablespace = 'SYSTEM'
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |          - USERS WITH DEFAULT TEMPORARY TABLESPACE - (SYSTEM) -            |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_default_temporary_tablespace_as_system"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With Default Temporary Tablespace - (SYSTEM)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                 FORMAT a75    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a125   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a125   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a75    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a75    HEADING 'Account Status'          ENTMAP off

SELECT
    '<font color="#336699"><b>'  || username             || '</font></b>'                  username
  , '<div align="center">'       || default_tablespace   || '</div>'                       default_tablespace
  , '<div align="center">'       || temporary_tablespace || '</div>'                       temporary_tablespace
  , '<div align="right">'        || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  created
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="center"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM
    dba_users
WHERE
    temporary_tablespace = 'SYSTEM'
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                  - OBJECTS IN THE SYSTEM TABLESPACE -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="objects_in_the_system_tablespace"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Objects in the SYSTEM Tablespace</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner               FORMAT a40                   HEADING 'Owner'           ENTMAP off
COLUMN segment_name        FORMAT a100                  HEADING 'Segment Name'    ENTMAP off
COLUMN segment_type        FORMAT a75                   HEADING 'Type'            ENTMAP off
COLUMN tablespace_name     FORMAT a50                  HEADING 'Tablespace'      ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999   HEADING 'Bytes|Alloc'     ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999   HEADING 'Extents'         ENTMAP off
COLUMN max_extents         FORMAT 999,999,999,999,999   HEADING 'Max|Ext'         ENTMAP off
COLUMN initial_extent      FORMAT 999,999,999,999,999   HEADING 'Initial|Ext'     ENTMAP off
COLUMN next_extent         FORMAT 999,999,999,999,999   HEADING 'Next|Ext'        ENTMAP off
COLUMN pct_increase        FORMAT 999,999,999,999,999   HEADING 'Pct|Inc'         ENTMAP off

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Total Count: </b></font>' OF segment_name ON report
COMPUTE sum   LABEL '<font color="#990000"><b>Total Bytes: </b></font>' OF bytes ON report

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , segment_name
  , segment_type
  , tablespace_name
  , bytes
  , extents
  , initial_extent
  , next_extent
  , pct_increase
FROM
    dba_segments
WHERE
      owner NOT IN ('SYS','SYSTEM')
  AND tablespace_name = 'SYSTEM'
ORDER BY
    owner
  , segment_name
  , extents DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                  - NO Primary-Key Table  -               			        |
-- +----------------------------------------------------------------------------+

prompt <a name="no-primary-key-table"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>NO Primary-Key Table</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a40                  HEADING 'Owner'           ENTMAP off

BREAK ON report

select a.owner, count(*)
  from all_tables a
 where a.owner &str_owner2
   and a.table_name not in
       (select c.table_name
          from dba_cons_columns b, dba_constraints c
         where b.constraint_name = c.constraint_name
           and c.constraint_type = 'P'
           and b.owner &str_owner2)
 group by a.owner;


-- +----------------------------------------------------------------------------+
-- |                  - MATERIALIZED VIEW  -               					    |
-- +----------------------------------------------------------------------------+

prompt <a name="mviews_list"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>MATERIALIZED VIEW</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a40                  HEADING 'Owner'           ENTMAP off
COLUMN MVIEW_NAME        FORMAT a50                  HEADING 'Mview_Name'    ENTMAP off
COLUMN QUERY       		 FORMAT a100                 HEADING 'Query'            ENTMAP off

BREAK ON report ON owner

select owner,MVIEW_NAME,QUERY from dba_mviews;

-- +----------------------------------------------------------------------------+
-- |                              - RECYCLE BIN -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_recycle_bin"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Recycle Bin</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES
COLUMN owner               FORMAT a85                   HEADING 'Owner'           ENTMAP off

BREAK ON report
select owner,count(*) from dba_recyclebin group by owner;

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner               FORMAT a85                   HEADING 'Owner'           ENTMAP off
COLUMN original_name                                    HEADING 'Original|Name'   ENTMAP off
COLUMN type                                             HEADING 'Object|Type'     ENTMAP off
COLUMN object_name                                      HEADING 'Object|Name'     ENTMAP off
COLUMN ts_name                                          HEADING 'Tablespace'      ENTMAP off
COLUMN operation                                        HEADING 'Operation'       ENTMAP off
COLUMN createtime                                       HEADING 'Create|Time'     ENTMAP off
COLUMN droptime                                         HEADING 'Drop|Time'       ENTMAP off
COLUMN can_undrop                                       HEADING 'Can|Undrop?'     ENTMAP off
COLUMN can_purge                                        HEADING 'Can|Purge?'      ENTMAP off
COLUMN bytes_kb               FORMAT 999,999,999,999,999   HEADING 'Bytes_KB'           ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , original_name
  , type
  , object_name
  , ts_name
  , operation
  , '<div nowrap align="right">'  || NVL(createtime, '<br>') || '</div>' createtime
  , '<div nowrap align="right">'  || NVL(droptime, '<br>')   || '</div>' droptime
  , DECODE(   can_undrop
            , null
            , '<BR>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || can_undrop || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || can_undrop || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || can_undrop || '</b></font></div>')   can_undrop
  , DECODE(   can_purge
            , null
            , '<BR>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || can_purge || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || can_purge || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || can_purge || '</b></font></div>')    can_purge
  , (space * p.blocksize)/1024 bytes_kb
FROM
    dba_recyclebin r
  , (SELECT value blocksize FROM v$parameter WHERE name='db_block_size') p
ORDER BY
    owner
  , object_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

set termout       ON
prompt 60% Collect Database Backup Information...... 
set termout       off 

-- +============================================================================+
-- |                                                                            |
-- |             <<<<<     Database  Backup Information     >>>>>               |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database  Backup Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP JOBS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Jobs</b></font><hr align="left" width="460">

prompt <b>Last 50 RMAN backup jobs</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING 'Backup Name'          ENTMAP off
COLUMN start_time            FORMAT a75    HEADING 'Start Time'           ENTMAP off
COLUMN elapsed_time          FORMAT a75    HEADING 'Elapsed Time'         ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN input_type                          HEADING 'Input Type'           ENTMAP off
COLUMN output_device_type                  HEADING 'Output Devices'       ENTMAP off
COLUMN input_size                          HEADING 'Input Size'           ENTMAP off
COLUMN output_size                         HEADING 'Output Size'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING 'Output Rate Per Sec'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select
         command_id
       , start_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details
     order by start_time DESC
    ) r
WHERE
    rownum < 51; 

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - RMAN CONFIGURATION -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_configuration"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Configuration</b></font><hr align="left" width="460">

prompt <b>All non-default RMAN configuration settings</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT a130   HEADING 'Name'   ENTMAP off
COLUMN value                  HEADING 'Value'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || name || '</font></b></div>'   name
  , value
FROM
    v$rman_configuration
ORDER BY
    name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP SETS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_sets"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets</b></font><hr align="left" width="460">

prompt <b>Available backup sets contained in the control file including available and expired backup sets</b>
prompt <b>Last 30 RMAN backup sets</b>
CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                    HEADING 'BS Key'                 ENTMAP off
COLUMN backup_type            FORMAT a70                    HEADING 'Backup Type'            ENTMAP off
COLUMN device_type                                          HEADING 'Device Type'            ENTMAP off
COLUMN controlfile_included   FORMAT a30                    HEADING 'Controlfile Included?'  ENTMAP off
COLUMN spfile_included        FORMAT a30                    HEADING 'SPFILE Included?'       ENTMAP off
COLUMN incremental_level                                    HEADING 'Incremental Level'      ENTMAP off
COLUMN pieces                 FORMAT 999,999,999,999        HEADING '# of Pieces'            ENTMAP off
COLUMN start_time             FORMAT a75                    HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a75                    HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999    HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN tag                                                  HEADING 'Tag'                    ENTMAP off
COLUMN block_size             FORMAT 999,999,999,999,999    HEADING 'Block Size'             ENTMAP off
COLUMN keep                   FORMAT a40                    HEADING 'Keep?'                  ENTMAP off
COLUMN keep_until             FORMAT a75                    HEADING 'Keep Until'             ENTMAP off
COLUMN keep_options           FORMAT a15                    HEADING 'Keep Options'           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF pieces elapsed_seconds ON report

SELECT *
  FROM (SELECT '<div align="center"><font color="#336699"><b>' || bs.recid ||
               '</b></font></div>' bs_key,
               DECODE(backup_type,
                      'L',
                      '<div nowrap><font color="#990000">Archived Redo Logs</font></div>',
                      'D',
                      '<div nowrap><font color="#000099">Datafile Full Backup</font></div>',
                      'I',
                      '<div nowrap><font color="darkgreen">Incremental Backup</font></div>') backup_type,
               '<div nowrap align="right">' || device_type || '</div>' device_type,
               '<div align="center">' ||
               DECODE(bs.controlfile_included,
                      'NO',
                      '-',
                      bs.controlfile_included) || '</div>' controlfile_included,
               '<div align="center">' || NVL(sp.spfile_included, '-') ||
               '</div>' spfile_included,
               bs.incremental_level incremental_level,
               bs.pieces pieces,
               '<div nowrap align="right">' ||
               TO_CHAR(bs.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>' start_time,
               '<div nowrap align="right">' ||
               TO_CHAR(bs.completion_time, 'mm/dd/yyyy HH24:MI:SS') ||
               '</div>' completion_time,
               bs.elapsed_seconds elapsed_seconds,
               bp.tag tag,
               bs.block_size block_size,
               '<div align="center">' || bs.keep || '</div>' keep,
               '<div nowrap align="right">' ||
               NVL(TO_CHAR(bs.keep_until, 'mm/dd/yyyy HH24:MI:SS'), '<br>') ||
               '</div>' keep_until,
               bs.keep_options keep_options
          FROM v$backup_set bs,
               (select distinct set_stamp, set_count, tag, device_type
                  from v$backup_piece
                 where status in ('A', 'X')) bp,
               (select distinct set_stamp, set_count, 'YES' spfile_included
                  from v$backup_spfile) sp
         WHERE bs.set_stamp = bp.set_stamp
           AND bs.set_count = bp.set_count
           AND bs.set_stamp = sp.set_stamp(+)
           AND bs.set_count = sp.set_count(+)
         ORDER BY bs.recid DESC)
 where rownum < 31;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - RMAN BACKUP PIECES -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_pieces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Pieces</b></font><hr align="left" width="460">

prompt <b>Available backup pieces contained in the control file including available and expired backup sets</b>
prompt <b>Last 30 RMAN backup pices</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key              FORMAT a75                     HEADING 'BS Key'            ENTMAP off
COLUMN piece#                                             HEADING 'Piece #'           ENTMAP off
COLUMN copy#                                              HEADING 'Copy #'            ENTMAP off
COLUMN bp_key                                             HEADING 'BP Key'            ENTMAP off
COLUMN status                                             HEADING 'Status'            ENTMAP off
COLUMN handle                                             HEADING 'Handle'            ENTMAP off
COLUMN start_time          FORMAT a75                     HEADING 'Start Time'        ENTMAP off
COLUMN completion_time     FORMAT a75                     HEADING 'End Time'          ENTMAP off
COLUMN elapsed_seconds     FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'   ENTMAP off
COLUMN deleted             FORMAT a10                     HEADING 'Deleted?'          ENTMAP off

BREAK ON bs_key

SELECT *
  FROM (SELECT '<div align="center"><font color="#336699"><b>' || bs.recid ||
               '</b></font></div>' bs_key,
               bp.piece# piece#,
               bp.copy# copy#,
               bp.recid bp_key,
               DECODE(status,
                      'A',
                      '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>',
                      'D',
                      '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>',
                      'X',
                      '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>') status,
               handle handle,
               '<div nowrap align="right">' ||
               TO_CHAR(bp.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>' start_time,
               '<div nowrap align="right">' ||
               TO_CHAR(bp.completion_time, 'mm/dd/yyyy HH24:MI:SS') ||
               '</div>' completion_time,
               bp.elapsed_seconds elapsed_seconds
          FROM v$backup_set bs, v$backup_piece bp
         WHERE bs.set_stamp = bp.set_stamp
           AND bs.set_count = bp.set_count
           AND bp.status IN ('A', 'X')
         ORDER BY bs.recid DESC)
 where rownum < 31;
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - RMAN BACKUP CONTROL FILES -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Control Files</b></font><hr align="left" width="460">

prompt <b>Available automatic control files within all available (and expired) backup sets</b>
prompt <b>Last 10 RMAN backup control files</b>
CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN controlfile_included   FORMAT a75                     HEADING 'Controlfile Included?'  ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT *
  FROM (SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'                      ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included)  ||
    '</b></font></div>'                                                                             controlfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid DESC)
 where rownum < 11;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP SPFILE -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_spfile"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup SPFILE</b></font><hr align="left" width="460">

prompt <b>Available automatic SPFILE backups within all available (and expired) backup sets</b>
prompt <b>Last 10 RMAN backup spfile</b>
CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN spfile_included        FORMAT a75                     HEADING 'SPFILE Included?'       ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT *
  FROM (SELECT '<div align="center"><font color="#336699"><b>' || bs.recid ||
               '</b></font></div>' bs_key,
               bp.piece# piece#,
               bp.copy# copy#,
               bp.recid bp_key,
               '<div align="center"><font color="#663300"><b>' ||
               NVL(sp.spfile_included, '-') || '</b></font></div>' spfile_included,
               DECODE(status,
                      'A',
                      '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>',
                      'D',
                      '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>',
                      'X',
                      '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>') status,
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
         ORDER BY bs.recid DESC)
 where rownum < 11;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                           - DIRECTORIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directories"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directories</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a75  HEADING 'Owner'             ENTMAP off
COLUMN directory_name    FORMAT a75  HEADING 'Directory Name'    ENTMAP off
COLUMN directory_path                HEADING 'Directory Path'    ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner          || '</b></font></div>'  owner
  , '<b><font color="#663300">'                   || directory_name || '</font></b>'        directory_name
  , '<tt>' || directory_path || '</tt>' directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                        - DIRECTORY PRIVILEGES -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directory_privileges"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directory Privileges</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN table_name    FORMAT a75      HEADING 'Directory Name'    ENTMAP off
COLUMN grantee       FORMAT a75      HEADING 'Grantee'           ENTMAP off
COLUMN privilege     FORMAT a75      HEADING 'Privilege'         ENTMAP off
COLUMN grantable     FORMAT a75      HEADING 'Grantable?'        ENTMAP off

BREAK ON report ON table_name ON grantee

SELECT
    '<b><font color="#336699">' || table_name || '</font></b>'  table_name
  , '<b><font color="#663300">' || grantee    || '</font></b>'  grantee
  , privilege                                                   privilege
  , DECODE(   grantable
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || grantable || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || grantable || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || grantable || '</b></font></div>')   grantable
FROM
    dba_tab_privs
WHERE
    privilege IN ('READ', 'WRITE')
ORDER BY
    table_name
  , grantee
  , privilege;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                           - DATA PUMP JOBS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner_name         FORMAT a75            HEADING 'Owner Name'         ENTMAP off
COLUMN job_name           FORMAT a75            HEADING 'Job Name'           ENTMAP off
COLUMN operation          FORMAT a75            HEADING 'Operation'          ENTMAP off
COLUMN job_mode           FORMAT a75            HEADING 'Job Mode'           ENTMAP off
COLUMN state              FORMAT a75            HEADING 'State'              ENTMAP off
COLUMN degree             FORMAT 999,999,999    HEADING 'Degree'             ENTMAP off
COLUMN attached_sessions  FORMAT 999,999,999    HEADING 'Attached Sessions'  ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>' || dpj.owner_name || '</b></font></div>'  owner_name
  , dpj.job_name                                                                            job_name
  , dpj.operation                                                                           operation
  , dpj.job_mode                                                                            job_mode
  , dpj.state                                                                               state
  , dpj.degree                                                                              degree
  , dpj.attached_sessions                                                                   attached_sessions
FROM
    dba_datapump_jobs      dpj
ORDER BY
    dpj.owner_name
  , dpj.job_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - DATA PUMP SESSIONS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_sessions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Sessions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75            HEADING 'Instance Name'    ENTMAP off
COLUMN owner_name           FORMAT a75            HEADING 'Owner Name'       ENTMAP off
COLUMN job_name             FORMAT a75            HEADING 'Job Name'         ENTMAP off
COLUMN session_type         FORMAT a75            HEADING 'Session Type'     ENTMAP off
COLUMN sid                                        HEADING 'SID'              ENTMAP off
COLUMN serial_no                                  HEADING 'Serial#'          ENTMAP off
COLUMN oracle_username      FORMAT a75            HEADING 'Oracle Username'  ENTMAP off
COLUMN os_username          FORMAT a75            HEADING 'O/S Username'     ENTMAP off
COLUMN os_pid                                     HEADING 'O/S PID'          ENTMAP off

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name  || '</b></font></div>'  instance_name_print
  , dj.owner_name                                                                               owner_name 
  , dj.job_name                                                                                 job_name
  , ds.type                                                                                     session_type
  , s.sid                                                                                       sid
  , s.serial#                                                                                   serial_no
  , s.username                                                                                  oracle_username
  , s.osuser                                                                                    os_username
  , p.spid                                                                                      os_pid
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$process              p
WHERE
      s.inst_id  = i.inst_id
  AND s.inst_id  = p.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND s.paddr    = p.addr (+)
  AND dj.job_id  = ds.job_id
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>





-- +----------------------------------------------------------------------------+
-- |                        - DATA PUMP JOB PROGRESS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_job_progress"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Job Progress</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75                 HEADING 'Instance Name'           ENTMAP off
COLUMN owner_name           FORMAT a75                 HEADING 'Owner Name'              ENTMAP off
COLUMN job_name             FORMAT a75                 HEADING 'Job Name'                ENTMAP off
COLUMN session_type         FORMAT a75                 HEADING 'Session Type'            ENTMAP off
COLUMN start_time                                      HEADING 'Start Time'              ENTMAP off
COLUMN time_remaining       FORMAT 9,999,999,999,999   HEADING 'Time Remaining (min.)'   ENTMAP off
COLUMN sofar                FORMAT 9,999,999,999,999   HEADING 'Bytes Completed So Far'  ENTMAP off
COLUMN totalwork            FORMAT 9,999,999,999,999   HEADING 'Total Bytes for Job'     ENTMAP off
COLUMN pct_completed                                   HEADING '% Completed'             ENTMAP off

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name  || '</b></font></div>'   instance_name_print
  , dj.owner_name                                                                                owner_name 
  , dj.job_name                                                                                  job_name
  , ds.type                                                                                      session_type
  , '<div align="center" nowrap>' || TO_CHAR(sl.start_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'  start_time
  , ROUND(sl.time_remaining/60,0)                                                                time_remaining
  , sl.sofar                                                                                     sofar
  , sl.totalwork                                                                                 totalwork
  , '<div align="right">' || TRUNC(ROUND((sl.sofar/sl.totalwork) * 100, 1)) || '%</div>'         pct_completed
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$session_longops      sl
WHERE
      s.inst_id  = i.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND sl.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND dj.job_id  = ds.job_id
  AND sl.sid     = s.sid
  AND sl.serial# = s.serial#
  AND ds.type    = 'MASTER'
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


set termout       ON
prompt 75% Collect Database Performance Information...... 
set termout       off 

-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database Performance Information     >>>>>                |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database Performance Information</u></b></font></center>

prompt <tr><th align="left"><b>Note:</b></th><tr>
prompt <tr><th align="left"><b>SQL tuning parts, please run tools : sopcollect.</b></th><tr>

-- +----------------------------------------------------------------------------+
-- |                             - Wait Event summary   -                       |
-- +----------------------------------------------------------------------------+

prompt <a name="wait_event_Summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Wait Event Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN event 		  FORMAT a120                HEADING 'Wait Event Name'    ENTMAP off
COLUMN count          FORMAT 9,999,999,999        HEADING 'Wait Event Total Count'        ENTMAP off

BREAK ON report ON event

select 
'<div align="left"><font color="#336699"><b>' || event || '</b></font></div>'  event
,count(*) count 
from v$session_wait 
group by event order by 2 desc
/
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - CURRENT SESSIONS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="current_sessions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Current Sessions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a45    HEADING 'Instance Name'              ENTMAP off
COLUMN thread_number_print  FORMAT a45    HEADING 'Thread Number'              ENTMAP off
COLUMN count                FORMAT a45    HEADING 'Current No. of Processes'   ENTMAP off
COLUMN value                FORMAT a45    HEADING 'Max No. of Processes'       ENTMAP off
COLUMN pct_usage            FORMAT a45    HEADING '% Usage'                    ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || a.instance_name  || '</b></font></div>'  instance_name_print
  , '<div align="center">' || a.thread#             || '</div>'  thread_number_print
  , '<div align="center">' || TO_CHAR(a.count)      || '</div>'  count
  , '<div align="center">' || b.value               || '</div>'  value
  , '<div align="center">' || TO_CHAR(ROUND(100*(a.count / b.value), 2)) || '%</div>'  pct_usage
FROM
    (select   count(*) count, a1.inst_id, a2.instance_name, a2.thread#
     from     gv$session a1
            , gv$instance a2
     where    a1.inst_id = a2.inst_id
     group by a1.inst_id
            , a2.instance_name
            , a2.thread#) a
  , (select value, inst_id from gv$parameter where name='processes') b
WHERE
    a.inst_id = b.inst_id
ORDER BY
    a.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                  - Locking Information -                                   |
-- +----------------------------------------------------------------------------+

prompt <a name="locking_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Locking Information Medium Detail</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

BREAK ON report ON INST_ID
select * from gv$lock where block=1; 

CLEAR COLUMNS BREAKS COMPUTES

BREAK ON report

COLUMN res  HEADING 'Res_Type'    ENTMAP off
COLUMN sid FORMAT 999999  HEADING 'SID'    ENTMAP off
COLUMN serial# FORMAT 999999  HEADING 'Serial#'    ENTMAP off
COLUMN id1 FORMAT 9999999  HEADING 'Id1'    ENTMAP off
COLUMN id2 FORMAT 9999999  HEADING 'Id2'    ENTMAP off
COLUMN lmode FORMAT a14  HEADING 'Lock Held'    ENTMAP off
COLUMN request FORMAT a14  HEADING 'Lock Req.'    ENTMAP off
COLUMN username FORMAT a30  HEADING 'Username'    ENTMAP off
COLUMN terminal FORMAT a10  HEADING 'Terminal'    ENTMAP off
COLUMN tab FORMAT a10  HEADING 'Table'    ENTMAP off
COLUMN owner FORMAT 999  HEADING 'Owner'    ENTMAP off

select  l.sid,s.serial#,s.username,s.terminal, 
        decode(l.type,'RW','RW - Row Wait Enqueue', 
                    'TM','TM - DML Enqueue', 
                    'TX','TX - Trans Enqueue', 
                    'UL','UL - User',l.type||'System') res, 
        substr(t.name,1,10) tab,u.name owner, 
        l.id1,l.id2, 
        decode(l.lmode,1,'No Lock', 
                2,'Row Share', 
                3,'Row Exclusive', 
                4,'Share', 
                5,'Shr Row Excl', 
                6,'Exclusive',null) lmode, 
        decode(l.request,1,'No Lock', 
                2,'Row Share', 
                3,'Row Excl', 
                4,'Share', 
                5,'Shr Row Excl', 
                6,'Exclusive',null) request 
from v$lock l, v$session s, 
sys.user$ u,sys.obj$ t 
where l.sid = s.sid 
and s.type != 'BACKGROUND' 
and t.obj# = l.id1 
and u.user# = t.owner# 
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                             - SGA INFORMATION -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA Information</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79                 HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a150                HEADING 'Pool Name'        ENTMAP off
COLUMN value         FORMAT 999,999,999,999,999 HEADING 'Size(MB)'            ENTMAP off

BREAK ON report ON instance_name
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF value ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , '<div align="left"><font color="#336699"><b>' || s.name          || '</b></font></div>'  name
  , s.value/1024/1024                                                                                  value
FROM
    gv$sga       s
  , gv$instance  i
WHERE
    s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.value DESC;


prompt Modify the SGA_TARGET parameter (up to the size of the SGA_MAX_SIZE, if necessary) to reduce
prompt the number of "Estimated Physical Reads".

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79     HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a79     HEADING 'Parameter Name'   ENTMAP off
COLUMN value         FORMAT a79     HEADING 'Value(MB)'            ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.name    name
  , (CASE p.name
         WHEN 'sga_max_size' THEN '<div align="right">' || TO_CHAR(p.value/1024/1024, '999,999,999,999,999') || '</div>'
         WHEN 'sga_target'   THEN '<div align="right">' || TO_CHAR(p.value/1024/1024, '999,999,999,999,999') || '</div>'
     ELSE
         '<div align="right">' || p.value/1024/1024 || '</div>'
     END) value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('sga_max_size', 'sga_target')
ORDER BY
    i.instance_name
  , p.name;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name         FORMAT a79                   HEADING 'Instance Name'              ENTMAP off
COLUMN sga_size              FORMAT 999,999,999,999,999   HEADING 'SGA Size'                   ENTMAP off
COLUMN sga_size_factor       FORMAT 999,999,999,999,999   HEADING 'SGA Size Factor'            ENTMAP off
COLUMN estd_db_time          FORMAT 999,999,999,999,999   HEADING 'Estimated DB Time'          ENTMAP off
COLUMN estd_db_time_factor   FORMAT 999,999,999,999,999   HEADING 'Estimated DB Time Factor'   ENTMAP off
COLUMN estd_physical_reads   FORMAT 999,999,999,999,999   HEADING 'Estimated Physical Reads'   ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , s.sga_size
  , s.sga_size_factor
  , s.estd_db_time
  , s.estd_db_time_factor
  , s.estd_physical_reads
FROM
    gv$sga_target_advice s
  , gv$instance  i
WHERE
    s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.sga_size_factor;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - SGA (ASMM) DYNAMIC COMPONENTS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_asmm_dynamic_components"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA (ASMM) Dynamic Components</b></font><hr align="left" width="460">

prompt Provides a summary report of all dynamic components as part of the Automatic Shared Memory
prompt Management (ASMM) configuration. This will display the total real memory allocation for the current
prompt SGA from the V$SGA_DYNAMIC_COMPONENTS view, which contains both manual and autotuned SGA components.
prompt As with the other manageability features of Oracle Database 10g, ASMM requires you to set the 
prompt STATISTICS_LEVEL parameter to at least TYPICAL (the default) before attempting to enable ASMM. ASMM
prompt can be enabled by setting SGA_TARGET to a nonzero value in the initialization parameter file (pfile/spfile).

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name         FORMAT a79                HEADING 'Instance Name'        ENTMAP off
COLUMN component             FORMAT a79                HEADING 'Component Name'       ENTMAP off
COLUMN current_size          FORMAT 999,999,999,999    HEADING 'CurrentSize_MB'         ENTMAP off
COLUMN min_size              FORMAT 999,999,999,999    HEADING 'MinSize_MB'             ENTMAP off
COLUMN max_size              FORMAT 999,999,999,999    HEADING 'MaxSize_MB'             ENTMAP off
COLUMN user_specified_size   FORMAT 999,999,999,999    HEADING 'UserSpecified|Size_MB'  ENTMAP off
COLUMN oper_count            FORMAT 999,999,999,999    HEADING 'Oper.|Count'          ENTMAP off
COLUMN last_oper_type        FORMAT a75                HEADING 'Last Oper.|Type'      ENTMAP off
COLUMN last_oper_mode        FORMAT a75                HEADING 'Last Oper.|Mode'      ENTMAP off
COLUMN last_oper_time        FORMAT a75                HEADING 'Last Oper.|Time'      ENTMAP off
COLUMN granule_size          FORMAT 999,999,999,999    HEADING 'GranuleSize_MB'         ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , sdc.component
  , sdc.current_size/1024/1024 current_size
  , sdc.min_size/1024/1024 min_size
  , sdc.max_size/1024/1024 max_size
  , sdc.user_specified_size/1024/1024 user_specified_size
  , sdc.oper_count
  , sdc.last_oper_type
  , sdc.last_oper_mode
  , '<div align="right">' || NVL(TO_CHAR(sdc.last_oper_time, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   last_oper_time
  , sdc.granule_size/1024/1024 granule_size
FROM
    gv$sga_dynamic_components sdc
  , gv$instance  i
ORDER BY
    i.instance_name
  , sdc.component DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - PGA TARGET ADVICE -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="pga_target_advice"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>PGA Target Advice</b></font><hr align="left" width="460">

prompt The <b>V$PGA_TARGET_ADVICE</b> view predicts how the statistics cache hit percentage and over
prompt allocation count in V$PGASTAT will be impacted if you change the value of the
prompt initialization parameter PGA_AGGREGATE_TARGET. When you set the PGA_AGGREGATE_TARGET and
prompt WORKAREA_SIZE_POLICY to <b>AUTO</b> then the *_AREA_SIZE parameter are automatically ignored and
prompt Oracle will automatically use the computed value for these parameters. Use the results from
prompt the query below to adequately set the initialization parameter PGA_AGGREGATE_TARGET as to avoid
prompt any over allocation. If column ESTD_OVERALLOCATION_COUNT in the V$PGA_TARGET_ADVICE
prompt view (below) is nonzero, it indicates that PGA_AGGREGATE_TARGET is too small to even
prompt meet the minimum PGA memory needs. If PGA_AGGREGATE_TARGET is set within the over
prompt allocation zone, the memory manager will over-allocate memory and actual PGA memory
prompt consumed will be more than the limit you set. It is therefore meaningless to set a
prompt value of PGA_AGGREGATE_TARGET in that zone. After eliminating over-allocations, the
prompt goal is to maximize the PGA cache hit percentage, based on your response-time requirement
prompt and memory constraints.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79     HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a79     HEADING 'Parameter Name'   ENTMAP off
COLUMN value         FORMAT a79     HEADING 'Value_MB'            ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.name    name
  , (CASE p.name
         WHEN 'pga_aggregate_target' THEN '<div align="right">' || TO_CHAR(p.value/1024/1024, '999,999,999,999,999')  || '</div>'
     ELSE
         '<div align="right">' || p.value || '</div>'
     END) value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('pga_aggregate_target', 'workarea_size_policy')
ORDER BY
    i.instance_name
  , p.name;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name                  FORMAT a79                   HEADING 'Instance Name'               ENTMAP off
COLUMN pga_target_for_estimate        FORMAT 999,999,999,999,999   HEADING 'PGA Target for Estimate_MB'     ENTMAP off
COLUMN pga_target_factor           FORMAT 999,999,999,999,999      HEADING 'Pga_Target_Factor'   ENTMAP off
COLUMN estd_pga_cache_hit_percentage  FORMAT 999,999,999,999,999   HEADING 'Estimated PGA Cache Hit %'   ENTMAP off
COLUMN estd_overalloc_count           FORMAT 999,999,999,999,999   HEADING 'ESTD_OVERALLOC_COUNT'        ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.pga_target_for_estimate/1024/1024 pga_target_for_estimate
  , p.pga_target_factor
  , p.estd_pga_cache_hit_percentage
  , p.estd_overalloc_count
FROM
    gv$pga_target_advice p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , p.pga_target_for_estimate;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                           - AWR SNAPSHOT LIST -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_snapshot_list"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Snapshot List</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75               HEADING 'Instance Name'          ENTMAP off
COLUMN snap_id              FORMAT a75               HEADING 'Snap ID'                ENTMAP off
COLUMN startup_time         FORMAT a75               HEADING 'Instance Startup Time'  ENTMAP off
COLUMN begin_interval_time  FORMAT a75               HEADING 'Begin Interval Time'    ENTMAP off
COLUMN end_interval_time    FORMAT a75               HEADING 'End Interval Time'      ENTMAP off
COLUMN elapsed_time         FORMAT 999,999,999.99    HEADING 'Elapsed Time (min)'     ENTMAP off
COLUMN db_time              FORMAT 999,999,999.99    HEADING 'DB Time (min)'          ENTMAP off
COLUMN pct_db_time          FORMAT a75               HEADING '% DB Time'              ENTMAP off
COLUMN cpu_time             FORMAT 999,999,999.99    HEADING 'CPU Time (min)'         ENTMAP off

BREAK ON instance_name_print ON startup_time

SELECT /*+rule*/ 
    '<div align="center"><font color="#336699"><b>' || i.instance_name                                         || '</b></font></div>'  instance_name_print
  , '<div align="center"><font color="#336699"><b>' || s.snap_id                                               || '</b></font></div>'  snap_id
  , '<div nowrap align="right">'                    || TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')        || '</div>'             startup_time
  , '<div nowrap align="right">'                    || TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             begin_interval_time
  , '<div nowrap align="right">'                    || TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')   || '</div>'             end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)                                                    elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                                                                           db_time
  , '<div align="right">' || 
        ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                    EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                    EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                    EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2) 
                             || ' %</div>'                                                                                             pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
    i.instance_number   = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - AWR SNAPSHOT SIZE ESTIMATES -                       |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_snapshot_size_estimates"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Snapshot Size Estimates</b></font><hr align="left" width="460">

DECLARE

    CURSOR get_instances IS
        SELECT COUNT(DISTINCT instance_number)
        FROM wrm$_database_instance;
  
    CURSOR get_wr_control_info IS
        SELECT snapint_num, retention_num
        FROM wrm$_wr_control;
  
    CURSOR get_snaps IS
        SELECT
            SUM(all_snaps)
          , SUM(good_snaps)
          , SUM(today_snaps)
          , SYSDATE - MIN(begin_interval_time)
        FROM
            (SELECT
                  1 AS all_snaps
                , (CASE WHEN s.status = 0 THEN 1 ELSE 0 END) AS good_snaps
                , (CASE WHEN (s.end_interval_time > SYSDATE - 1) THEN 1 ELSE 0 END) AS today_snaps
                , CAST(s.begin_interval_time AS DATE) AS begin_interval_time
             FROM wrm$_snapshot s
             );

    CURSOR sysaux_occ_usage IS
        SELECT
            occupant_name
          , schema_name
          , space_usage_kbytes/1024 space_usage_mb
        FROM
            v$sysaux_occupants
        ORDER BY
            space_usage_kbytes DESC
          , occupant_name;
  
    mb_format           CONSTANT  VARCHAR2(30)  := '99,999,990.0';
    kb_format           CONSTANT  VARCHAR2(30)  := '999,999,990';
    pct_format          CONSTANT  VARCHAR2(30)  := '990.0';
    snapshot_interval   NUMBER;
    retention_interval  NUMBER;
    all_snaps           NUMBER;
    awr_size            NUMBER;
    snap_size           NUMBER;
    awr_average_size    NUMBER;
    est_today_snaps     NUMBER;
    awr_size_past24     NUMBER;
    good_snaps          NUMBER;
    today_snaps         NUMBER;
    num_days            NUMBER;
    num_instances       NUMBER;

BEGIN

    OPEN get_instances;
    FETCH get_instances INTO num_instances;
    CLOSE get_instances;

    OPEN get_wr_control_info;
    FETCH get_wr_control_info INTO snapshot_interval, retention_interval;
    CLOSE get_wr_control_info;

    OPEN get_snaps;
    FETCH get_snaps INTO all_snaps, good_snaps, today_snaps, num_days;
    CLOSE get_snaps;

    FOR occ_rec IN sysaux_occ_usage
    LOOP
        IF (occ_rec.occupant_name = 'SM/AWR') THEN
            awr_size := occ_rec.space_usage_mb;
        END IF;
    END LOOP;

    snap_size := awr_size/all_snaps;
    awr_average_size := snap_size*86400/snapshot_interval;

    today_snaps := today_snaps / num_instances;

    IF (num_days < 1) THEN
        est_today_snaps := ROUND(today_snaps / num_days);
    ELSE
        est_today_snaps := today_snaps;
    END IF;

    awr_size_past24 := snap_size * est_today_snaps;
    
    DBMS_OUTPUT.PUT_LINE('<table width="90%" border="1">');

    DBMS_OUTPUT.PUT_LINE('<tr><th align="center" colspan="3">Estimates based on ' || ROUND(snapshot_interval/60) || ' minute snapshot intervals</th></tr>');
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/day</td><td align="right">'
                            || TO_CHAR(awr_average_size, mb_format)
                            || ' MB</td><td align="right">(' || TRIM(TO_CHAR(snap_size*1024, kb_format)) || ' K/snap * '
                            || ROUND(86400/snapshot_interval) || ' snaps/day)</td></tr>' );
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_average_size * 7, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per instance</td></tr>' );
    IF (num_instances > 1) THEN
        DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_average_size * 7 * num_instances, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per database</td></tr>' );
    END IF;

    DBMS_OUTPUT.PUT_LINE('<tr><th align="center" colspan="3">Estimates based on ' || ROUND(today_snaps) || ' snaps in past 24 hours</th></tr>');

    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/day</td><td align="right">'
                            || TO_CHAR(awr_size_past24, mb_format)
                            || ' MB</td><td align="right">('
                            || TRIM(TO_CHAR(snap_size*1024, kb_format)) || ' K/snap and '
                            || ROUND(today_snaps) || ' snaps in past '
                            || ROUND(least(num_days*24,24),1) || ' hours)</td></tr>' );
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_size_past24 * 7, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per instance</td></tr>' );
    IF (num_instances > 1) THEN
        DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_size_past24 * 7 * num_instances, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per database</td></tr>' );
    END IF;
  
    DBMS_OUTPUT.PUT_LINE('</table>');
    
END;
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - FILE I/O STATISTICS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="file_io_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>File I/O Statistics</b></font><hr align="left" width="460">

prompt <b>Ordered by "Physical Reads" since last startup of the Oracle instance</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name   FORMAT a50                   HEAD 'Tablespace'       ENTMAP off
COLUMN fname                                          HEAD 'File Name'        ENTMAP off
COLUMN phyrds            FORMAT 999,999,999,999,999   HEAD 'Physical Reads'   ENTMAP off
COLUMN phywrts           FORMAT 999,999,999,999,999   HEAD 'Physical Writes'  ENTMAP off
COLUMN read_pct                                       HEAD 'Read Pct.'        ENTMAP off
COLUMN write_pct                                      HEAD 'Write Pct.'       ENTMAP off
COLUMN total_io          FORMAT 999,999,999,999,999   HEAD 'Total I/O'        ENTMAP off

BREAK ON tablespace_name

COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF phyrds phywrts total_io ON report

SELECT
    '<font color="#336699"><b>' || df.tablespace_name || '</b></font>'                      tablespace_name
  , df.file_name                             fname
  , fs.phyrds                                phyrds
  , '<div align="right">' || ROUND((fs.phyrds * 100) / (fst.pr + tst.pr), 2) || '%</div>'   read_pct
  , fs.phywrts                               phywrts
  , '<div align="right">' || ROUND((fs.phywrts * 100) / (fst.pw + tst.pw), 2) || '%</div>'   write_pct
  , (fs.phyrds + fs.phywrts)                 total_io
FROM
    sys.dba_data_files df
  , v$filestat         fs
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    df.file_id = fs.file#
UNION
SELECT
    '<font color="#336699"><b>' || tf.tablespace_name || '</b></font>'                     tablespace_name
  , tf.file_name                           fname
  , ts.phyrds                              phyrds
  , '<div align="right">' || ROUND((ts.phyrds * 100) / (fst.pr + tst.pr), 2) || '%</div>'  read_pct
  , ts.phywrts                             phywrts
  , '<div align="right">' || ROUND((ts.phywrts * 100) / (fst.pw + tst.pw), 2) || '%</div>' write_pct
  , (ts.phyrds + ts.phywrts)                 total_io
FROM
    sys.dba_temp_files  tf
  , v$tempstat          ts
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    tf.file_id = ts.file#
ORDER BY phyrds DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - FILE I/O TIMINGS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="file_io_timings"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>File I/O Timings</b></font><hr align="left" width="460">

prompt <b>Average time (in milliseconds) for an I/O call per datafile since last startup of the Oracle instance - (ordered by Physical Reads)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN fname                                           HEAD 'File Name'                                      ENTMAP off
COLUMN phyrds            FORMAT 999,999,999,999,999    HEAD 'Physical Reads'                                 ENTMAP off
COLUMN read_rate         FORMAT 999,999,999,999,999.99 HEAD 'Average Read Time<br>(milliseconds per read)'   ENTMAP off
COLUMN phywrts           FORMAT 999,999,999,999,999    HEAD 'Physical Writes'                                ENTMAP off
COLUMN write_rate        FORMAT 999,999,999,999,999.99 HEAD 'Average Write Time<br>(milliseconds per write)' ENTMAP off

BREAK ON REPORT
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF phyrds phywrts ON report
COMPUTE avg LABEL '<font color="#990000"><b>Average: </b></font>' OF read_rate write_rate ON report

SELECT
    '<b><font color="#336699">' || d.name || '</font></b>'  fname
  , s.phyrds                                     phyrds
  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2)   read_rate
  , s.phywrts                                    phywrts
  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2)  write_rate
FROM
    v$filestat  s
  , v$datafile  d
WHERE
  s.file# = d.file#
UNION
SELECT
    '<b><font color="#336699">' || t.name || '</font></b>'  fname
  , s.phyrds                                     phyrds
  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2)   read_rate
  , s.phywrts                                    phywrts
  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2)  write_rate
FROM
    v$tempstat  s
  , v$tempfile  t
WHERE
  s.file# = t.file#
ORDER BY
    2 DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - Index and Table Degree Check -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="index_table_degree_check"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Index and Table Degree Check</b></font><hr align="left" width="460">

prompt <b>Check Index Degree:</b>
prompt <b>How to exist, treatment method: alter table indexname noparallel</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a30                             HEAD 'Owner'                                      ENTMAP off
COLUMN table_name        FORMAT a60                             HEAD 'Table_Name'                                      ENTMAP off
COLUMN index_name        FORMAT a60                             HEAD 'Index_Name'                                      ENTMAP off
COLUMN index_type        FORMAT a40                             HEAD 'Index_Type'                                      ENTMAP off
COLUMN degree       	 FORMAT 99999999                        HEAD 'Degree'                                      ENTMAP off
COLUMN partitioned       FORMAT a40                             HEAD 'Partitioned'                                      ENTMAP off
COLUMN status        	 FORMAT a40                             HEAD 'Status'                                      ENTMAP off
COLUMN LAST_ANALYZED   	 FORMAT a100        			        HEADING 'LAST_ANALYZED'   	 					ENTMAP off

BREAK ON REPORT  ON owner

select  '<div align="left"><font color="#336699"><b>' || owner || '</b></font></div>'  owner,
       table_name,
       index_name,
       index_type,
	   '<div align="left"><font color="#990000"><b>' || degree || '</b></font></div>' degree
       ,partitioned
	   ,LAST_ANALYZED
       ,status
  from dba_indexes
 where degree > '1';

prompt
prompt
prompt <b>Check Table Degree:</b>
prompt <b>How to exist, treatment method: alter tablename noparallel</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a30                             HEAD 'Owner'                                      ENTMAP off
COLUMN table_name        FORMAT a60                             HEAD 'Table_Name'                                      ENTMAP off
COLUMN degree       	 FORMAT 99999999                        HEAD 'Degree'                                      ENTMAP off
COLUMN partitioned       FORMAT a40                             HEAD 'Partitioned'                                      ENTMAP off
COLUMN status        	 FORMAT a40                             HEAD 'Status'                                      ENTMAP off
COLUMN LAST_ANALYZED   	 FORMAT a100        			        HEADING 'LAST_ANALYZED'   	 ENTMAP off


BREAK ON REPORT  ON owner

select '<div align="left"><font color="#336699"><b>' || owner ||
       '</b></font></div>' owner,
       table_name,
       '<div align="left"><font color="#990000"><b>' || degree ||
       '</b></font></div>' degree,
       PARTITIONED,
       LAST_ANALYZED,
       STATUS
  from dba_tables
 where degree > 1
    or degree > '1';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                           - FULL TABLE SCANS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="full_table_scans"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Full Table Scans</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN large_table_scans   FORMAT 999,999,999,999,999  HEADING 'Large Table Scans'   ENTMAP off
COLUMN small_table_scans   FORMAT 999,999,999,999,999  HEADING 'Small Table Scans'   ENTMAP off
COLUMN pct_large_scans                                 HEADING 'Pct. Large Scans'    ENTMAP off

SELECT
    a.value large_table_scans
  , b.value small_table_scans
  , '<div align="right">' || ROUND(100*a.value/DECODE((a.value+b.value),0,1,(a.value+b.value)),2) || '%</div>' pct_large_scans
FROM
    v$sysstat  a
  , v$sysstat  b
WHERE
      a.name = 'table scans (long tables)'
  AND b.name = 'table scans (short tables)';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                - SORTS -                                   |
-- +----------------------------------------------------------------------------+

prompt <a name="sorts"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Sorts</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN disk_sorts     FORMAT 999,999,999,999,999    HEADING 'Disk Sorts'       ENTMAP off
COLUMN memory_sorts   FORMAT 999,999,999,999,999    HEADING 'Memory Sorts'     ENTMAP off
COLUMN pct_disk_sorts                               HEADING 'Pct. Disk Sorts'  ENTMAP off

SELECT
    a.value   disk_sorts
  , b.value   memory_sorts
  , '<div align="right">' || ROUND(100*a.value/DECODE((a.value+b.value),0,1,(a.value+b.value)),2) || '%</div>' pct_disk_sorts
FROM
    v$sysstat  a
  , v$sysstat  b
WHERE
      a.name = 'sorts (disk)'
  AND b.name = 'sorts (memory)';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                      - HIGH WATER MARK STATISTICS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="high_water_mark_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>High Water Mark Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN statistic_name        FORMAT a115                    HEADING 'Statistic Name'
COLUMN version               FORMAT a62                     HEADING 'Version'
COLUMN highwater             FORMAT 9,999,999,999,999,999   HEADING 'Highwater'
COLUMN last_value            FORMAT 9,999,999,999,999,999   HEADING 'Last Value'
COLUMN description           FORMAT a120                    HEADING 'Description'

SELECT
    '<div align="left"><font color="#336699"><b>' || name || '</b></font></div>'  statistic_name
  , '<div align="right">' || version || '</div>'                                  version
  , highwater                                                                     highwater
  , last_value                                                                    last_value
  , description                                                                   description
FROM dba_high_water_mark_statistics
ORDER BY name;

CLEAR COLUMNS BREAKS COMPUTES

COLUMN table_name        FORMAT a30                    HEADING 'Table_Name' ENTMAP off
COLUMN HWM_Space_KB        FORMAT 99999999                    HEADING 'HWM_Space_KB' ENTMAP off
COLUMN Use_Space_KB        FORMAT 99999999                    HEADING 'HWM_Space_KB' ENTMAP off
COLUMN Reserved_Space_KB   FORMAT 99999999                    HEADING 'HWM_Space_KB' ENTMAP off
COLUMN Waste_Space_KB      FORMAT 99999999                    HEADING 'HWM_Space_KB' ENTMAP off

SELECT table_name, ROUND ((blocks * 8), 2) "HWM_Space_KB",
   ROUND ((num_rows * avg_row_len / 1024), 2) "Use_Space_KB",
   ROUND ((blocks * 10 / 100) * 8, 2) "Reserved_Space_KB",
   ROUND ((  blocks * 8
           - (num_rows * avg_row_len / 1024)
           - blocks * 8 * 10 / 100
          ),
          2
         ) "Waste_Space_KB"
  FROM dba_tables
  WHERE table_name = 'TABLE_NAME';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +----------------------------------------------------------------------------+
-- |                            - OUTLINE HINTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_outline_hints"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Outline Hints</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN category       FORMAT a125    HEADING 'Category'        ENTMAP off
COLUMN owner          FORMAT a125    HEADING 'Owner'           ENTMAP off
COLUMN name           FORMAT a125    HEADING 'Name'            ENTMAP off
COLUMN node                          HEADING 'Node'            ENTMAP off
COLUMN join_pos                      HEADING 'Join Position'   ENTMAP off
COLUMN hint                          HEADING 'Hint'            ENTMAP off

BREAK ON category ON owner ON name

SELECT
    '<div nowrap><font color="#336699"><b>' || a.category || '</b></font></div>' category
  , a.owner                                           owner
  , a.name                                            name
  , '<div align="center">' || b.node || '</div>'      node
  , '<div align="center">' || b.join_pos || '</div>'  join_pos
  , b.hint                                            hint
FROM
    dba_outlines       a
  , dba_outline_hints  b
WHERE
      a.owner = b.owner
  AND b.name  = b.name
ORDER BY
    category
  , owner
  , name;
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |           - TABLES SUFFERING FROM ROW MIGRATION -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="tables_suffering_from_row_chaining_migration"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tables Suffering From Row Migration</b></font><hr align="left" width="460">

prompt <b><font color="#990000">NOTE</font>: Tables must have statistics gathered</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                          HEADING 'Owner'           ENTMAP off
COLUMN table_name                                     HEADING 'Table Name'      ENTMAP off
COLUMN partition_name                                 HEADING 'Partition Name'  ENTMAP off
COLUMN num_rows           FORMAT 999,999,999,999,999  HEADING 'Total Rows'      ENTMAP off
COLUMN pct_chained_rows   FORMAT a65                  HEADING '% Chained Rows'  ENTMAP off
COLUMN avg_row_length     FORMAT 999,999,999,999,999  HEADING 'Avg Row Length'  ENTMAP off

SELECT
    owner                               owner
  , table_name                          table_name
  , ''                                  partition_name
  , num_rows                            num_rows
  , '<div align="right">' || ROUND((chain_cnt/num_rows)*100, 2) || '%</div>' pct_chained_rows
  , avg_row_len                         avg_row_length
FROM
    (select
         owner
       , table_name
       , chain_cnt
       , num_rows
       , avg_row_len 
     from
         sys.dba_tables 
     where
           chain_cnt is not null 
       and num_rows is not null 
       and chain_cnt > 0 
       and num_rows > 0 
       and owner != 'SYS')  
UNION ALL 
SELECT
    table_owner                         owner
  , table_name                          table_name
  , partition_name                      partition_name
  , num_rows                            num_rows
  , '<div align="right">' || ROUND((chain_cnt/num_rows)*100, 2) || '%</div>' pct_chained_rows
  , avg_row_len                         avg_row_length
FROM
    (select
         table_owner
       , table_name
       , partition_name
       , chain_cnt
       , num_rows
       , avg_row_len 
     from
         sys.dba_tab_partitions 
     where
           chain_cnt is not null 
       and num_rows is not null 
       and chain_cnt > 0 
       and num_rows > 0 
       and table_owner != 'SYS') b 
WHERE
    (chain_cnt/num_rows)*100 > 10;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS by Elapsed Time  -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_by_elapsed_time"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements by Elapsed Time</b></font><hr align="left" width="460">

prompt <b>Top 10 SQL statements by Elapsed Time.Time:seconds </b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner     FORMAT 999999.99   HEADING 'owner'         ENTMAP off
COLUMN elapsed_time     FORMAT 999999.99   HEADING 'Elapsed_time'         ENTMAP off
COLUMN cpu_time         FORMAT 999999.99    HEADING 'Cpu_time'         ENTMAP off
COLUMN wait_time        FORMAT 999999.99   HEADING 'Wait_time'         ENTMAP off
COLUMN executions  		FORMAT 9999999999   HEADING 'executions'  ENTMAP off
COLUMN Per_Time          FORMAT 999999.99          HEADING 'Per_Time'           ENTMAP off
COLUMN hash_value  		FORMAT 9999999999   HEADING 'hash_value'  ENTMAP off
COLUMN SORTS  		FORMAT 9999999999   HEADING 'SORTS'  ENTMAP off
COLUMN buffer_gets  		FORMAT 9999999999   HEADING 'buffer_gets'  ENTMAP off
COLUMN disk_reads  		FORMAT 9999999999   HEADING 'buffer_gets'  ENTMAP off
COLUMN USER_IO_WAIT_TIME  		FORMAT 99999999.99   HEADING 'USER_IO_WAIT_TIME'  ENTMAP off

select rownum as rank, a.*
  from (select PARSING_SCHEMA_NAME owner,
               SQL_FULLTEXT,
               elapsed_Time/1000/1000 elapsed_time,
               cpu_time/1000/1000 cpu_time,
               elapsed_Time/1000/1000 - cpu_time/1000/1000 wait_time,
               trunc((elapsed_Time - cpu_time) * 100 / elapsed_Time, 2) "wait_time_per%",
               executions,
               (elapsed_Time/1000/1000) / (executions + 1) Per_Time,
               buffer_gets,
               disk_reads,
               hash_value,
               USER_IO_WAIT_TIME/1000/1000 IO_WTIME,
               SORTS
          from v$sqlarea t
         where elapsed_time/1000/1000 > 5 and PARSING_SCHEMA_NAME not in ('SYS','SYSTEM','ORACLE_OCM ','CTXSYS','APPQOSSYS','DBSNMP','SCOTT','OUTLN','QUEST','SYSMAN','ORDSYS','OLAPSYS','MDSYS','EXFSYS','XDB','CTXSYS','DMSYS','WMSYS')  
         order by elapsed_time desc) a
 where rownum < 11
 order by Per_Time desc;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS by Executions -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_by_excutions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements by Executions</b></font><hr align="left" width="460">

prompt <b>Top 10 SQL statements by Executions</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN disk_reads     FORMAT 999,999,999,999,999   HEADING 'DiskReads'              ENTMAP off
COLUMN buffer_gets     FORMAT 999,999,999,999,999   HEADING 'BufferGets'              ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'              ENTMAP off
COLUMN gets_per_exec   FORMAT 999,999,999,999,999   HEADING 'Buffer_gets/Executions'           ENTMAP off
COLUMN sql_text                                     HEADING 'SQLText'                 ENTMAP off

SELECT *
  FROM (SELECT disk_reads,
               buffer_gets,
               executions,
               TRUNC(buffer_gets / executions) gets_per_exec,
               hash_value,
               sql_text
          FROM v$sqlarea
         WHERE executions > 0
         ORDER BY 3 DESC)
 WHERE ROWNUM < 11;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS by Disk_Reads -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_by_disk_reads"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements by Disk Reads</b></font><hr align="left" width="460">

prompt <b>Top 10 SQL statements by Disk Reads</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN disk_reads      FORMAT 999,999,999,999,999   HEADING 'DiskReads'         ENTMAP off
COLUMN buffer_gets      FORMAT 999,999,999,999,999   HEADING 'BufferGets'         ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'         ENTMAP off
COLUMN reads_per_exec  FORMAT 999,999,999,999,999   HEADING 'Reads / Execution'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'           ENTMAP off

SELECT *
  FROM (SELECT disk_reads,
               buffer_gets,
               executions,
               TRUNC(buffer_gets / executions) reads_per_exec,
               hash_value,
               sql_text
          FROM v$sqlarea
         WHERE executions > 0
         ORDER BY 1 DESC)
 WHERE ROWNUM < 11;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS by Buffer_Gets -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_by_buffer_gtes"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements by Buffer Gets</b></font><hr align="left" width="460">

prompt <b>Top 10 SQL statements by Buffer Gets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN disk_reads      FORMAT 999,999,999,999,999   HEADING 'DiskReads'         ENTMAP off
COLUMN buffer_gets      FORMAT 999,999,999,999,999   HEADING 'BufferGets'         ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'         ENTMAP off
COLUMN exec_per_buffer  FORMAT 999,999,999,999,999   HEADING 'Buffer_gets/Executions'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'           ENTMAP off

SELECT *
  FROM (SELECT disk_reads,
               buffer_gets,
               executions,
               TRUNC(buffer_gets / executions) exec_per_buffer,
               hash_value,
               sql_text
          FROM v$sqlarea
         WHERE executions > 0
         ORDER BY 2 DESC)
 WHERE ROWNUM < 11;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                     - END OF Database REPORT -                             |
-- +----------------------------------------------------------------------------+


set termout       ON
prompt 90% Collect Operating System Information..... 
set termout       off 
-- +============================================================================+
-- |                                                                            |
-- |            <<<<<  Operating System Information    >>>>>                    |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <a name="openating_system_information"></a>
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Operating System Information</u></b></font></center>

prompt 
!echo '<pre> '>dbcollect_temp.log 2> dbcollect_out_error.log
!export LANG=en_US
-- +----------------------------------------------------------------------------+
-- |                        - Listener And Tnsnames -                           |
-- +----------------------------------------------------------------------------+
!echo '<a name="Listener_And_Tnsnames"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Listener And Tnsnames</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>lsnrctl status:</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!lsnrctl status >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ps -ef|grep 'LISTENER -inherit':</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ps -ef|grep 'LISTENER -inherit' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat $ORACLE_HOME/network/admin/listener.ora</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat $ORACLE_HOME/network/admin/listener.ora >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat $GRID_HOME/network/admin/listener.ora >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat $ORACLE_HOME/network/admin/tnsnames.ora</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat $ORACLE_HOME/network/admin/tnsnames.ora >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat $ORACLE_HOME/network/admin/sqlnet.ora</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat $ORACLE_HOME/network/admin/sqlnet.ora >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat $GRID_HOME/network/admin/sqlnet.ora >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ls -ltr $ORACLE_HOME/network/log</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ls -ltr $ORACLE_HOME/network/log >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ls -ltr $GRID_HOME/network/log >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


-- +----------------------------------------------------------------------------+
-- |                        - Oracle Opatch -        	                        |
-- +----------------------------------------------------------------------------+
!echo '<a name="Oracle_Opatch"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle Opatch</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle Opatch</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!$ORACLE_HOME/OPatch/opatch lsinventory >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


-- +----------------------------------------------------------------------------+
-- |                        - Oracle Processes -                                |
-- +----------------------------------------------------------------------------+
!echo '<a name="Oracle_Processes"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle Processes</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ps -ef|grep ora_</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ps -ef|grep ora_ >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

-- +----------------------------------------------------------------------------+
-- |                        - Oracle Clusterware -                                |
-- +----------------------------------------------------------------------------+
!echo '<a name="Oracle_Clusterware"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Oracle Clusterware</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>crs_stat -t</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!crs_stat -t >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>crsctl status res -t</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!crsctl status res -t >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ocrcheck</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ocrcheck >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


-- +----------------------------------------------------------------------------+
-- |                        - Profile and Crontab -                             |
-- +----------------------------------------------------------------------------+
!echo '<a name="profile_and_crontab"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Profile and Crontab</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>env</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!env >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat /etc/passwd</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat /etc/passwd >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>crontab -l</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!crontab -l>>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

-- +----------------------------------------------------------------------------+
-- |                        - FileSystem -                                      |
-- +----------------------------------------------------------------------------+
!echo '<a name="FileSystem"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>FileSystem</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>aix:df -k or df -g,hp:bdf,linux:df -k or df -h</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>df -g</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!df -g >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>bdf</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!bdf >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>df -h</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!df -h >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>df -k</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!df -k >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

-- +----------------------------------------------------------------------------+
-- |                        - OS Version -                           			|
-- +----------------------------------------------------------------------------+
!echo '<a name="OS_Version"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>OS Version</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Os Version:aix:oslevel -r,linux:lsb_release -a,other:uname -a</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>oslevel -r</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!oslevel -r >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>uname -a</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!uname -a >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>lsb_release -a</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!lsb_release -a >>dbcollect_temp.log 2>> dbcollect_out_error.log

-- +----------------------------------------------------------------------------+
-- |                        - OS HOSTS -          	                 			|
-- +----------------------------------------------------------------------------+
!echo '<a name="Os_Hosts"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Os_etc_Hosts</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

 
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Os_etc_Hosts</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat /etc/hosts >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 


-- +----------------------------------------------------------------------------+
-- |                        - OS IP route -          	                 	    |
-- +----------------------------------------------------------------------------+
!echo '<a name="Os_ip_route"></a> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Os_ip_route</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

 
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>ifconfig -a</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!ifconfig -a >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>netstat -in</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!netstat -in >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>netstat -rn</b></font>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!netstat -rn >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

-- +----------------------------------------------------------------------------+
-- |                        - OS Vmstat -                           			|
-- +----------------------------------------------------------------------------+
!echo '<a name="OS_Vmstat"></a> ' >>dbcollect_temp.log 
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>OS Vmstat</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log

 
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>vmstat 2 10</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!vmstat 2 10 >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 

-- +----------------------------------------------------------------------------+
-- |                        - OS Swap -                           			    |
-- +----------------------------------------------------------------------------+
!echo '<a name="OS_Swapinfo"></a> ' >>dbcollect_temp.log
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>OS Swapinfo</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log

 
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>OS swap:aix:lsps -a,linux:free -m,hp-ux:swapinfo -tam</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>lsps -a</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!lsps -a >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>free -m</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!free -m >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>swapinfo -tam</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!swapinfo -tam >>dbcollect_temp.log 2>> dbcollect_out_error.log


-- +----------------------------------------------------------------------------+
-- |                        - Hardware Information -                            |
-- +----------------------------------------------------------------------------+
!echo '<a name="Hardware_Information"></a> ' >>dbcollect_temp.log
!echo '<font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Hardware Information</b></font><hr align="left" width="460"> ' >>dbcollect_temp.log

!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Hardware: aix and sun:prtconf,linux:cat /proc/meminfo;cat /proc/cpuinfo,hp:machinfo</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>prtconf</b></font>' >>dbcollect_temp.log
!prtconf '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!oslevel -s >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat /proc/meminfo</b></font>' >>dbcollect_temp.log 
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat /proc/meminfo >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>cat /proc/cpuinfo</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!cat /proc/cpuinfo >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<font size="+1" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>machinfo</b></font>' >>dbcollect_temp.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!machinfo >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log
!echo '<p>' >>dbcollect_temp.log 2>> dbcollect_out_error.log

!echo '</pre>' >>dbcollect_temp.log 2>> dbcollect_out_error.log 
prompt
prompt

SPOOL OFF

define reportHeader="<font size=+1 color=darkgreen><b>Fgedu Oracle Database Information Collect Tools v2.6</b></font><hr>Copyright(c)2008-2019.<a href="http://www.fgedu.net.cn" target="_blank">www.fgedu.net.cn</a> DBA Team.All Rights Reserved.Author QQ:176140749<p>"

!echo ' <center>[<a class="noLink" href="#top">Top</a>]</center><p> ' >>dbcollect_temp.log
!echo ' <center><font color=darkgreen><hr>Fgedu Oracle Database Information Collect Tools v2.6<p></font></center>' >>dbcollect_temp.log 
!echo ' <center><font color=darkgreen><hr>Fgedu All Study Tutorials£¨Oracle/MySQL/NoSQL£©£ºhttp://www.fgedu.net.cn/oracle.html<p></font></center>' >>dbcollect_temp.log 
!echo ' <center><font color=darkgreen>Opinion Feedback : mfkqwyc86@163.com,176140749@qq.com.<p></font></center>' >>dbcollect_temp.log
!echo ' <center><font color=darkgreen>Copyright(c)2008-2016.<a href="http://www.fgedu.net.cn" target="_blank">www.fgedu.net.cn</a> DBA Team.All Rights Reserved.Author:fgedu.<p></font></center>' >>dbcollect_temp.log
!cat dbcollect_temp.log >> &FileName._&_instance_name._&_spool_time..html
!del dbcollect26.sql >>dbcollect_temp.log 2>> dbcollect_out_error.log
!rm -f dbcollect26.sql >>dbcollect_temp.log 2>> dbcollect_out_error.log
!rm -f dbcollect_temp.log
!rm -f dbcollect_out_error.log

-- +----------------------------------------------------------------------------+
-- |                     - END OF ALL REPORT -                                  |
-- +----------------------------------------------------------------------------+

set termout       ON
prompt 100% Complete.
set termout       off

SET MARKUP HTML OFF
                        
SET TERMOUT ON
                          
define fileName=dbcollect26;
COLUMN spool_time NEW_VALUE _spool_time NOPRINT;
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;  
COLUMN dbname NEW_VALUE _dbname NOPRINT;
SELECT name dbname FROM v$database;
EXIT;
prompt Creating database report complete!