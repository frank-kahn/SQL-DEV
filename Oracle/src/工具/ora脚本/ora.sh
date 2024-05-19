#!/bin/sh
if [ "$LOGNAME" = "oracle" ];
then SQLPLUS_CMD="/ as sysdba";
ORA_SQL="/tmp/ora_format.sql";
else SQLPLUS_CMD="/ as sysdba";
ORA_SQL="/tmp/ora_format.sql";
fi

echo "set termout off" >> $ORA_SQL
echo "set serveroutput on" >> $ORA_SQL
echo "set pagesize 5000" >> $ORA_SQL
echo "alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';" >> $ORA_SQL
echo "alter session set nls_timestamp_format='yyyy-mm-dd hh24:mi:ss';" >> $ORA_SQL
echo "column plan_plus_exp format a80" >> $ORA_SQL
echo "column global_name new_value gname" >> $ORA_SQL
echo "set termout off" >> $ORA_SQL
echo "define gname=SQL" >> $ORA_SQL
echo "column global_name new_value gname" >> $ORA_SQL
echo "select lower(user)||'@'||lower(instance_name)||'('||(select distinct sid from v\$mystat)||')' global_name from v\$instance;" >> $ORA_SQL
echo "set sqlprompt '&gname> '" >> $ORA_SQL
echo "set termout on" >> $ORA_SQL

case $1 in 
si)
if [ "$LOGNAME" = "oracle" ];
then sqlplus "/ as sysdba" @$ORA_SQL
else sqlplus "/ as sysdba" @$ORA_SQL
fi
;;
dblink)
sqlplus -s "$SQLPLUS_CMD" << EOF
set linesize 240 pagesize 1000
col DB_LINK for a25
col HOST for a40
select * from dba_db_links;
exit
EOF
;;
log)
sqlplus -s "$SQLPLUS_CMD" << EOF
SELECT 'tail -100f '||VALUE||'/'||'alert_'||(SELECT INSTANCE_NAME FROM V\$INSTANCE)||'.log' "Diag Trace"
FROM V\$DIAG_INFO
WHERE NAME IN ('Diag Trace');
exit
EOF
;;
param)
sqlplus -s "$SQLPLUS_CMD" << EOF
alter session set cursor_sharing=force;
SELECT /* SHSNC */ NAME,ISDEFAULT,ISSES_MODIFIABLE SESMOD, ISSYS_MODIFIABLE SYSMOD,VALUE
FROM V\$PARAMETER 
WHERE NAME LIKE '%' || LOWER('$2') || '%' 
AND NAME <> 'control_files' 
and name <> 'rollback_segments' 
order by 1;
exit
EOF
;;
_param)
sqlplus -s "$SQLPLUS_CMD" << EOF
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
      x\$ksppi x,x\$ksppsv y 
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
exit
EOF
;;
highpara)
sqlplus -s "$SQLPLUS_CMD" << EOF
select 
  substr(sql_text, 1, 50) as sql_t, 
  trim(program), 
  min(sql_id), 
  count(*) 
from 
  (
    select 
      sql_text, 
      a.sql_id, 
      program 
    from 
      v\$session a,v\$sqlarea b 
    where 
      a.sql_id = b.sql_id 
      and a.status = 'ACTIVE' 
      and a.sql_id is not null 
    union all 
    select 
      sql_text, 
      a.PREV_SQL_ID as sql_id, 
      program 
    from 
      v\$session a,v\$sqlarea b 
    where 
      a.sql_id is null 
      and a.PREV_SQL_ID = b.sql_id 
      and a.status = 'ACTIVE'
  ) 
group by substr(sql_text, 1, 50),trim(program) 
order by  1;
exit
EOF
;;
sort)
sqlplus -s "$SQLPLUS_CMD" << EOF
SELECT /* SHSNC */ /*+ ordered */ 
       B.SID,
	   B.SERIAL#,
	   B.USERNAME,
	   B.MACHINE,
	   A.BLOCKS,
	   A.TABLESPACE,
	   A.SEGTYPE,
	   A.SEGFILE# FILE#,
	   A.SEGBLK# BLOCK# 
FROM V\$SORT_USAGE A,V\$SESSION B 
WHERE A.SESSION_ADDR = B.SADDR;
exit
EOF
;;
cost)
sqlplus -s "$SQLPLUS_CMD" << EOF
select 
  distinct sess.username, 
  nvl(decode(nvl(sess.module, sess.program),'SQL*Plus',sess.program,sess.module),sess.machine || ':' || sess.process) program, 
  sess.sql_id, 
  p.spid, 
  sess.event, 
  plan.cost 
from 
  v\$session sess,v\$sql_plan plan,v\$process p 
where 
  sess.sql_id = plan.sql_id 
  and plan.id = 0 
  and cost > $2 
  and sess.status = 'ACTIVE' 
  and p.addr = sess.paddr 
order by cost desc;
exit
EOF
;;
ddl)
sqlplus -s "$SQLPLUS_CMD" << EOF
SELECT dbms_metadata.get_ddl(upper('$3'),upper('$4'),upper('$2')) from dual;
exit
EOF
;;
pga)
sqlplus -s "$SQLPLUS_CMD" << EOF
select value / 1024 / 1024 "pga_aggregate_target(M)"
from v\$parameter where name = 'pga_aggregate_target';
select round(sum(pga_alloc_mem) / 1024 / 1024) alloc_mb,
round(sum(PGA_USED_MEM) / 1024 / 1024) used_mb from v\$process;
select s.sid, s.serial#, s.username, s.event, s.machine, s.program, s.sql_id,
round(p.pga_alloc_mem /1024/1024) size_m, p.spid
from v\$session s, v\$process p where s.paddr = p.addr 
-- 10485760 is 10 MB
and p.pga_alloc_mem > 10485760 
order by p.pga_alloc_mem desc;
exit
EOF
;;
shpool)
sqlplus -s "$SQLPLUS_CMD" << EOF
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select decode(sign(ksmchsiz - 812), -1,(ksmchsiz - 16) / 4, 
       decode(sign(ksmchsiz - 4012),-1,
	   trunc((ksmchsiz + 11924) / 64),
	   decode(sign(ksmchsiz - 65548),-1,
	   trunc(1 / log(ksmchsiz - 11, 2)) + 238,254))) bucket,
	   sum(ksmchsiz) free_space,
	   count(*) free_chunks,
	   trunc(avg(ksmchsiz)) average_size,
	   max(ksmchsiz) biggest from sys.x\$ksmsp
where inst_id = userenv('Instance')
      and ksmchcls = 'free'
group by decode(sign(ksmchsiz - 812), -1,(ksmchsiz - 16) / 4, 
          decode(sign(ksmchsiz - 4012),-1,
		  trunc((ksmchsiz + 11924) / 64),
		  decode(sign(ksmchsiz - 65548),-1,
		  trunc(1 / log(ksmchsiz - 11, 2)) + 238,254)))
order by 1;
exit
EOF
;;
sid)
sqlplus -s "$SQLPLUS_CMD" << EOF
select s.inst_id || ':' || s.sid || ',' || s.serial# sess,
       p.spid,
	   s.TYPE,
	   s.event,
	   S.P1 || '/' || S.P2 || '/' || S.P3 P123,
	   s.sql_id||'-'||s.PREV_SQL_ID sql_id,
	   s.status || ':' || s.last_call_et stat_time,
	   s.BLOCKING_INSTANCE || ':' || s.BLOCKING_SESSION BLOCKING,
	   s.USERNAME,
	   s.MACHINE,
	   s.PROGRAM,
	   s.SERVICE_NAME
from gv\$session s, gv\$process p
where s.paddr = p.addr
      and s.inst_id = p.inst_id 
	  and (s.sid = $2 or p.spid = $2);
exit
EOF
;;
active)
sqlplus -s "$SQLPLUS_CMD" << EOF
SELECT /* XJ LEADING(S) FIRST_ROWS */ S.SID, 
       S.SERIAL# S#,
	   P.SPID,
	   substr(NVL(S.USERNAME, SUBSTR(P.PROGRAM, LENGTH(P.PROGRAM) - 6)),1,10) USERNAME,
	   substr(S.MACHINE,1,20) MACHINE,
	   substr(S.EVENT,1,30) EVENT,
	   substr(S.P1 || '/' || S.P2 || '/' || S.P3,1,25) P123,
	   S.WAIT_TIME WT,
	   S.LAST_CALL_ET,
	   S.STATUS,
	   s.BLOCKING_INSTANCE || ':' || s.BLOCKING_SESSION BLOCKING,
	   NVL(SQL_ID, S.PREV_SQL_ID) SQL_ID
FROM V\$PROCESS P, V\$SESSION S 
WHERE P.ADDR = S.PADDR
      AND S.STATUS = 'ACTIVE'
	  AND P.BACKGROUND IS NULL;
exit
EOF
;;
longops)
sqlplus -s "$SQLPLUS_CMD" << EOF
select opname,
       TIME_REMAINING REMAIN,
	   ELAPSED_SECONDS ELAPSE,
	   MESSAGE,
	   SQL_ID,
	   sid,
	   username
from v\$session_longops
where TIME_REMAINING >0;
exit
EOF
;;
trans)
sqlplus -s "$SQLPLUS_CMD" << EOF
SELECT /* SHSNC */ /* RULE */ S.SID,
       S.SERIAL#,
	   s.status,
	   S.USERNAME,
	   R.NAME RBS,
	   T.START_TIME,
	   to_char(T.USED_UBLK)||','||to_char(T.USED_UREC) BLKS_RECS,
	   T.LOG_IO LOGIO,
	   T.PHY_IO PHYIO,
	   T.CR_GET CRGET,
	   T.CR_CHANGE CRMOD 
FROM V\$TRANSACTION T, V\$SESSION S,V\$ROLLNAME R, V\$ROLLSTAT RS
WHERE T.SES_ADDR(+) = S.SADDR
      AND T.XIDUSN = R.USN
	  AND S.USERNAME IS NOT NULL
	  AND R.USN = RS.USN;
exit
EOF
;;
append)
sqlplus -s "$SQLPLUS_CMD" << EOF
select 1 from dual;
exit
EOF
;;
*)
echo echo "Usage:";
echo " ora keyword [value1 [value2]] ";
echo " Oracle Tools "
echo " ORA : Release 1.0.2.1704"
;;
esac;
