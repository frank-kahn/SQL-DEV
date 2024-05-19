#!/bin/sh
 
if [ "$LOGNAME" = "oracle" ]; then
   SQLPLUS_CMD="/ as sysdba";
else
   SQLPLUS_CMD="/ as sysdba";
fi
 
case $1 in 
   si)
     if [ "$LOGNAME" = "oracle" ]; then
        sqlplus "/ as sysdba"
     else
        sqlplus "/ as sysdba"
     fi
     ;;
   sim)
     sqlplus "/ as sysdba"
     ;;
   res)
         sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 140
         set pagesize 2000
         set serveroutput on
         alter session set cursor_sharing=force;
         exec PRC_RSCTL_M('$2',$3);
         exit;
EOF
  ;;
 
 ke)
  sqlplus -s "$SQLPLUS_CMD" << EOF
  set line 300 pagesize 1000
  col username for a15
  col program for a40
  col osuser for a15
  col event for a30
  select sid,serial#,username,program,osuser,sql_id,event from v\$session where event#='$2' and osuser <> 'aee';
  select 'alter system kill session '''||sid||','||serial#||''' immediate;' from v\$session where event#='$2' and osuser <> 'aee';
  select 'ps -ef |grep '||to_char(spid)||'|grep LOCAL=NO|awk ''{print" -9 "\$2}''|xargs kill' kill_sh from v\$process p,v\$session s
 where s.paddr=p.addr and type='USER' and s.event#='$2' and osuser <> 'aee';
 exit
EOF
  ;;
 
  log)
  sqlplus -s "$SQLPLUS_CMD" << EOF
  select 'tail -300f '||value||'/alert*.log' from v\$parameter where name='background_dump_dest';
  exit    
EOF
  ;;
 
  asmfree)
  sqlplus -s "$SQLPLUS_CMD" << EOF
  set line 130 pagesize 1000
  select group_number,name,state,total_mb/1024,free_mb/1024 from v\$asm_diskgroup ;
  exit    
EOF
  ;;  
  
  undo)
  sqlplus -s "$SQLPLUS_CMD" << EOF
  set line 300 pages 150
  alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
  show parameter undo
  col tablespace_name for a30
  select t.tablespace_name,total_GB,free_GB,round(100*(1-free_GB/total_GB),3)||'%'"used_ts%"
        from (select tablespace_name,sum(bytes)/1024/1024/1024 total_GB from dba_data_files group by tablespace_name) t,
        (select tablespace_name,sum(bytes)/1024/1024/1024 free_GB from dba_free_space group by tablespace_name) f
   where t.tablespace_name=f.tablespace_name(+) and t.tablespace_name like '%UNDO%' order by tablespace_name;
 
  select tablespace_name,status,sum(bytes/1024/1024/1024) GB from dba_undo_extents group by tablespace_name,status;
  
  select u.begin_time,u.end_time,t.name "undo_tbs_name",u.undoblks "blocks_used",u.txncount "transactions",u.maxquerylen "longest query",
   u.expblkreucnt "expired blocks" from v\$undostat u , v\$tablespace t where u.undotsn=t.ts# and rownum <21
   order by undoblks desc ,maxquerylen;
  exit 
    
EOF
  ;;
 
  hplan)
  sqlplus -s "$SQLPLUS_CMD" << EOF
        set linesize 150 pagesize 1000
        alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
        select sql_id,sql_fulltext from v\$sql where sql_id ='$2';
        set line 300
        col sql_id for a15
        col operation for a20
        col options for a15
        col object_owner for a15
        col object_name for a20
        col timestamp for a20
        select sql_id , plan_hash_value, id, operation, options, object_owner, object_name, depth, cost, timestamp 
        from dba_hist_sql_plan where sql_id='$2' and TIMESTAMP=(sysdate-3) ;
 
        set line 200
        select a.instance_number,a.snap_id,a.sql_id,a.plan_hash_value,b.begin_interval_time 
        from dba_hist_sqlstat a,dba_hist_snapshot b where a.snap_id=b.snap_id and a.sql_id='$2'
        order by instance_number,snap_id;
        exit   
EOF
     ;;
 
   active)
         sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 140
         col sid format 9999
         col s# format 99999
         col username format a10
         col event format a30
         col machine format a20
         col p123 format a18
         col wt format 999
         col SQL_ID for a18
         alter session set cursor_sharing=force;
            SELECT /* XJ LEADING(S) FIRST_ROWS */
             S.SID,
             S.SERIAL# S#,
             P.SPID,
             NVL(S.USERNAME, SUBSTR(P.PROGRAM, LENGTH(P.PROGRAM) - 6)) USERNAME,
             S.MACHINE,
             S.EVENT,
             S.P1 || '/' || S.P2 || '/' || S.P3 P123,
             S.WAIT_TIME WT,
             NVL(SQL_ID, S.PREV_SQL_ID) SQL_ID
              FROM V\$PROCESS P, V\$SESSION S
             WHERE P.ADDR = S.PADDR
               AND S.STATUS = 'ACTIVE'
               AND P.BACKGROUND IS NULL;
         exit
EOF
     ;;
 
sess)
        sqlplus -s "$SQLPLUS_CMD" << EOF
        set linesize 400
        col sid format 99999
        col username format a13
        col spid for a10
        col event format a25
        col machine format a10
        col client_info format a15
        col module format a16
        col osuser format a10
        col status format a8
        col program format a15
        col wt format 999
        col SQL_ID for a13
        col LOGON_TIME for a15
        alter session set cursor_sharing=force;
                SELECT /* XJ LEADING(S) FIRST_ROWS */
                         S.SID,
                         P.SPID,
                         NVL(S.USERNAME, SUBSTR(P.PROGRAM, LENGTH(P.PROGRAM) - 6)) USERNAME,
                         MACHINE,
                         WAIT_TIME WT,
                         SQL_ID,
                         p.program,
                         client_info,
                         MODULE,
                         to_char(LOGON_TIME,'yyyy-mm-dd hh24:mi:ss') LOGON_TIME,
                         status,
                         osuser
                          FROM V\$PROCESS P, V\$SESSION S
                         WHERE P.ADDR = S.PADDR
                           AND S.SID = TO_NUMBER('$2');
        exit
EOF
;;
 
 
 tempfree)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     SET LINESIZE 500
     SET PAGESIZE 1000
     col TABLESPACE_NAME for a20
     col SUM(MB) for 999999999
     col USED(MB) for 999999999
     col FREE(MB) for 999999999
     SELECT d.tablespace_name "TABLESPACE_NAME",
     TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99999999') "SUM(MB)", 
     TO_CHAR(NVL(t.bytes,0)/1024/1024,'999999999') "USED(MB)", 
     TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "USED(%)",
     (a.bytes-t.bytes)/1024/1024 "FREE(MB)",
     d.status   "Status"
     FROM sys.dba_tablespaces d, 
     (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a, 
     (select tablespace_name, sum(bytes_cached) bytes from v\$temp_extent_pool group by tablespace_name) t 
     WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) AND d.contents like 'TEMPORARY'
     order by 4 desc;
     exit
EOF
      ;;
 
      
   tempfile)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col name format a60
         col file# format 9999
         col size_mb format 99999
         alter session set cursor_sharing=force;
         select /* SHSNC */ /*+ RULE */
            f.file#, F.NAME, TRUNC(f.BYTES/1048576,2) SIZE_MB , f.CREATION_TIME, status
         FROM V\$TEMPFILE F,V\$TABLESPACE T
         WHERE F.ts#=T.ts# AND T.NAME = NVL(UPPER('$2'),'SYSTEM')
         order by f.CREATION_TIME;
         exit
EOF
      ;;
 
 highpara)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     set linesize 150
     col sql_t format a50;                                       
      select substr(sql_text, 1, 50) as sql_t,
             trim(program),
             min(sql_id),
             count(*)
        from (select sql_text, a.sql_id, program
                from v\$session a, v\$sqlarea b
               where a.sql_id = b.sql_id
                 and a.status = 'ACTIVE'
                 and a.sql_id is not null
              union all
              select sql_text, a.PREV_SQL_ID as sql_id, program
                from v\$session a, v\$sqlarea b
               where a.sql_id is null
                 and a.PREV_SQL_ID = b.sql_id
                 and a.status = 'ACTIVE')
       group by substr(sql_text, 1, 50), trim(program)
       order by 4 desc,3;
               exit
EOF
     ;;
 
 event)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     set linesize 150 pages 999
    select inst_id, event#, event,count(*) from gv\$session
     where wait_class# <> 6
    group by inst_id, event#,event
    order by 1,4 desc;
               exit
EOF
     ;;     
 
   size)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col owner format a10
         col segment_name for a30
         alter session set cursor_sharing=force;
         SELECT /*+ SHSNC */ OWNER,SEGMENT_NAME, SEGMENT_TYPE, SUM(BYTES)/1048576 SIZE_MB, 
                    MAX(INITIAL_EXTENT) INIEXT, MAX(NEXT_EXTENT) MAXEXT FROM DBA_SEGMENTS 
             WHERE SEGMENT_NAME = upper('$2') 
               AND ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3')) 
               AND SEGMENT_TYPE LIKE 'TABLE%' 
             GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE 
           UNION ALL 
             SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, SUM(BYTES)/1048576 SIZE_MB, 
                    MAX(INITIAL_EXTENT) INIEXT, MAX(NEXT_EXTENT) MAXEXT FROM DBA_SEGMENTS 
             WHERE (OWNER,SEGMENT_NAME) IN ( 
                SELECT OWNER,INDEX_NAME FROM DBA_INDEXES WHERE TABLE_NAME=upper('$2') AND 
                ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3'))
                UNION 
                SELECT OWNER,SEGMENT_NAME FROM DBA_LOBS WHERE TABLE_NAME=upper('$2') AND 
                ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3')))
             GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE;
          exit
EOF
     ;;
 
   idxdesc)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     alter session set cursor_sharing=force;
      SET linesize 500
      col INDEX_COL  FOR a30
      col INDEX_TYPE FOR a22
      col INDEX_NAME FOR a32
      col table_name FOR a32
      SELECT B.OWNER||'.'||B.INDEX_NAME INDEX_NAME, 
             A.INDEX_COL,B.INDEX_TYPE||'-'||B.UNIQUENESS INDEX_TYPE,B.PARTITIONED
        FROM (SELECT TABLE_OWNER,TABLE_NAME,INDEX_NAME, SUBSTR(MAX(SYS_CONNECT_BY_PATH(COLUMN_NAME, ',')), 2) INDEX_COL
                FROM (SELECT TABLE_OWNER, TABLE_NAME,INDEX_NAME,  COLUMN_NAME,
                             ROW_NUMBER() OVER(PARTITION BY TABLE_OWNER, TABLE_NAME, INDEX_NAME 
                             ORDER BY TABLE_OWNER, INDEX_NAME, COLUMN_POSITION, COLUMN_NAME) RN
                        FROM DBA_IND_COLUMNS
                       WHERE TABLE_NAME = UPPER('$2')
                         AND TABLE_OWNER = UPPER('$3'))
               START WITH RN = 1
              CONNECT BY PRIOR RN = RN - 1
                     AND PRIOR TABLE_NAME = TABLE_NAME
                     AND PRIOR INDEX_NAME = INDEX_NAME
                     AND PRIOR TABLE_OWNER = TABLE_OWNER
               GROUP BY TABLE_NAME, INDEX_NAME, TABLE_OWNER
               ORDER BY TABLE_OWNER, TABLE_NAME, INDEX_NAME
             ) A,
            (SELECT * FROM DBA_INDEXES WHERE TABLE_NAME = UPPER('$2') AND TABLE_OWNER = UPPER('$3')) B
       WHERE A.TABLE_OWNER = B.TABLE_OWNER
         AND A.TABLE_NAME = B.TABLE_NAME
         AND A.INDEX_NAME =B.INDEX_NAME;  
         exit
EOF
     ;;
 
   tsfree)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     SET LINESIZE 500
     SET PAGESIZE 1000
     col FREE_SPACE(M) for 999999999
     col USED_SPACE(M) for 999999999
     col TABLESPACE_NAME for a20
     SELECT D.TABLESPACE_NAME,SPACE "SUM_SPACE(M)",SPACE - NVL(FREE_SPACE, 0) "USED_SPACE(M)",
            ROUND((1 - NVL(FREE_SPACE, 0) / SPACE) * 100, 2) "USED_RATE(%)", FREE_SPACE "FREE_SPACE(M)",
            case when FREE_SPACE=REA_FREE_SPACE then null else ROUND((1 - NVL(REA_FREE_SPACE, 0) / SPACE) * 100, 2) end "REA_USED_RATE(%)", 
            case when FREE_SPACE=REA_FREE_SPACE then null else REA_FREE_SPACE end "REA_FREE_SPACE(M)"
     FROM 
       (SELECT TABLESPACE_NAME, ROUND(SUM(BYTES) / (1024 * 1024), 2) SPACE
        FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) D,
       ( SELECT F1.TABLESPACE_NAME, F1.FREE_SPACE-NVL(F2.FREE_SPACE,0) REA_FREE_SPACE,F1.FREE_SPACE
         FROM
         (SELECT TABLESPACE_NAME, ROUND(SUM(BYTES) / (1024 * 1024), 2) FREE_SPACE 
           FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME
         ) F1,
         (SELECT TS_NAME TABLESPACE_NAME, ROUND(SUM(SPACE)*8/1024,2) FREE_SPACE
           FROM  DBA_RECYCLEBIN GROUP BY TS_NAME  
         ) F2
         WHERE F1.TABLESPACE_NAME=F2.TABLESPACE_NAME(+)
       ) F      
      WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)
      ORDER BY  1 - NVL(REA_FREE_SPACE, 0) / SPACE DESC;
         exit
EOF
      ;;
 
   tablespace)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120 pagesize 1000
         alter session set cursor_sharing=force;
         select /* SHSNC */
            TABLESPACE_NAME TS_NAME,INITIAL_EXTENT INI_EXT,NEXT_EXTENT NXT_EXT,
            STATUS,CONTENTS, EXTENT_MANAGEMENT EXT_MGR,ALLOCATION_TYPE ALLOC_TYPE 
         FROM DBA_TABLESPACES ORDER BY TABLESPACE_NAME;
         exit
EOF
      ;;
 
   datafile)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120 pagesize 1000
         col name format a60
         col file# format 9999
         col size_mb format 99999
         alter session set cursor_sharing=force;
         select /* SHSNC */ /*+ RULE */
            f.file#, F.NAME, TRUNC(f.BYTES/1048576,2) SIZE_MB , f.CREATION_TIME, status
         FROM V\$DATAFILE F,V\$TABLESPACE T
         WHERE F.ts#=T.ts# AND T.NAME = NVL(UPPER('$2'),'SYSTEM')
         order by f.CREATION_TIME;
         exit
EOF
     ;;
 
   sqltext)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         alter session set cursor_sharing=force;
         set pagesize 1000
         SELECT /* SHSNC */ SQL_TEXT FROM V\$SQLTEXT 
          WHERE SQL_ID = to_char('$2')
          ORDER BY PIECE;
         exit
EOF
   ;;
 
   plan)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         alter session set cursor_sharing=force;
         set linesize 150 pagesize 1000
         SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(to_char('$2'),NULL));
         exit
EOF
     ;;
 
   lock)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120 pagesize 1000
         col type format a12
         col hold format a12
         col request format a12
         col BLOCK_OTHERS format a16
         alter session set cursor_sharing=force;
         select /* SHSNC */ /*+ RULE */ 
            sid,
            decode(type, 
                    'MR', 'Media Recovery', 
                    'RT', 'Redo Thread', 
                    'UN', 'User Name', 
                    'TX', 'Transaction', 
                    'TM', 'DML', 
                    'UL', 'PL/SQL User Lock', 
                    'DX', 'Distributed Xaction', 
                    'CF', 'Control File', 
                    'IS', 'Instance State', 
                    'FS', 'File Set', 
                    'IR', 'Instance Recovery', 
                    'ST', 'Disk Space Transaction', 
                    'TS', 'Temp Segment', 
                    'IV', 'Library Cache Invalidation', 
                    'LS', 'Log Start or Switch', 
                    'RW', 'Row Wait', 
                    'SQ', 'Sequence Number', 
                    'TE', 'Extend Table', 
                    'TT', 'Temp Table', 
                    'TC', 'Thread Checkpoint', 
                                'SS', 'Sort Segment', 
                                'JQ', 'Job Queue', 
                                'PI', 'Parallel operation', 
                                'PS', 'Parallel operation', 
                                'DL', 'Direct Index Creation', 
                    type) type, 
            decode(lmode, 
                    0, 'None',            
                    1, 'Null',            
                    2, 'Row-S (SS)',      
                    3, 'Row-X (SX)',      
                    4, 'Share',           
                    5, 'S/Row-X (SSX)',   
                    6, 'Exclusive',       
                    to_char(lmode)) hold, 
             decode(request, 
                    0, 'None',            
                    1, 'Null',            
                    2, 'Row-S (SS)',      
                    3, 'Row-X (SX)',      
                    4, 'Share',           
                    5, 'S/Row-X (SSX)',   
                    6, 'Exclusive',       
                    to_char(request)) request, 
             ID1,ID2,CTIME, 
             decode(block, 
                    0, 'Not Blocking',  
                    1, 'Blocking',      
                    2, 'Global',        
                    to_char(block)) block_others 
                from v\$lock 
            where type <> 'MR' and to_char(sid) = nvl('$2',to_char(sid)) ;
         exit
EOF
     ;;
 
   lockwait)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 180 pagesize 1000
         col HOLD_SID format 99999
         col WAIT_SID format 99999
         col type format a20
         col hold format a12
         col request format a12
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ /*+ ORDERED USE_HASH(H,R) */ 
            H.SID HOLD_SID, 
            R.SID WAIT_SID, 
            decode(H.type, 
                    'MR', 'Media Recovery', 
                    'RT', 'Redo Thread', 
                    'UN', 'User Name', 
                    'TX', 'Transaction', 
                    'TM', 'DML', 
                    'UL', 'PL/SQL User Lock', 
                    'DX', 'Distributed Xaction', 
                    'CF', 'Control File', 
                    'IS', 'Instance State', 
                    'FS', 'File Set', 
                    'IR', 'Instance Recovery', 
                    'ST', 'Disk Space Transaction', 
                    'TS', 'Temp Segment', 
                    'IV', 'Library Cache Invalidation', 
                    'LS', 'Log Start or Switch', 
                    'RW', 'Row Wait', 
                    'SQ', 'Sequence Number', 
                    'TE', 'Extend Table', 
                    'TT', 'Temp Table', 
                    'TC', 'Thread Checkpoint', 
                                'SS', 'Sort Segment', 
                                'JQ', 'Job Queue', 
                                'PI', 'Parallel operation', 
                                'PS', 'Parallel operation', 
                                'DL', 'Direct Index Creation', 
                    H.type) type, 
            decode(H.lmode, 
                    0, 'None',         1, 'Null', 
                    2, 'Row-S (SS)',   3, 'Row-X (SX)', 
                    4, 'Share',        5, 'S/Row-X (SSX)', 
                    6, 'Exclusive',    to_char(H.lmode)) hold, 
             decode(r.request,         0, 'None', 
                    1, 'Null',         2, 'Row-S (SS)', 
                    3, 'Row-X (SX)',   4, 'Share', 
                    5, 'S/Row-X (SSX)',6, 'Exclusive', 
                    to_char(R.request)) request, 
            R.ID1,R.ID2,R.CTIME 
          FROM V\$LOCK H,V\$LOCK R 
          WHERE H.BLOCK = 1 AND R.REQUEST > 0 AND H.SID <> R.SID 
            and H.TYPE <> 'MR' AND R.TYPE <> 'MR' 
            AND H.ID1 = R.ID1 AND H.ID2 = R.ID2 AND H.TYPE=R.TYPE 
            AND H.LMODE > 0 AND R.REQUEST > 0 ORDER BY 1,2;
         exit
EOF
      ;;
 
   objlike)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col type format a16
         col OWNER format a12
         col status format a8
         col CREATED format a10
         col MODIFIED format a19
         col OBJECT_NAME format a30
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ OBJECT_TYPE TYPE,OBJECT_ID ID,OWNER,OBJECT_NAME, 
               TO_CHAR(CREATED,'YYYY/MM/DD') CREATED, 
               TO_CHAR(LAST_DDL_TIME,'YYYY/MM/DD HH24:MI:SS') MODIFIED,STATUS 
           FROM ALL_OBJECTS 
           WHERE OBJECT_TYPE IN ('CLUSTER','FUNCTION','INDEX',
                'PACKAGE','PROCEDURE','SEQUENCE','SYNONYM',
                'TABLE','TRIGGER','TYPE','VIEW') 
             AND ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3')) 
             AND OBJECT_NAME LIKE UPPER('%$2%');
         exit
EOF
      ;;
 
   tablike)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col OWNER format a12
         col status format a8
         col CREATED format a10
         col MODIFIED format a19
         col OBJECT_NAME format a30
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ OBJECT_ID ID,OWNER,OBJECT_NAME,
               TO_CHAR(CREATED,'YYYY/MM/DD') CREATED,
               TO_CHAR(LAST_DDL_TIME,'YYYY/MM/DD HH24:MI:SS') MODIFIED,STATUS
           FROM ALL_OBJECTS
           WHERE OBJECT_TYPE = 'TABLE'
             AND ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3'))
             AND OBJECT_NAME LIKE UPPER('%$2%');
         exit
EOF
      ;;
 
   tstat)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 150
         col owner format a10
         col partname format a30
         col INIEXT format 99999
         col nxtext format 99999
         col avgspc format 99999
         col ccnt format 999
         col rowlen format 9999
         col ssize format 9999999
         alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ 
            OWNER,NULL PARTNAME, 
            NUM_ROWS NROWS, BLOCKS, AVG_SPACE AVGSPC,CHAIN_CNT CCNT, AVG_ROW_LEN ROWLEN, 
            SAMPLE_SIZE SSIZE,LAST_ANALYZED ANADATE 
         FROM ALL_TABLES 
         WHERE UPPER(OWNER)=NVL(UPPER('$3'),OWNER)  AND TABLE_NAME=UPPER('$2') 
         UNION ALL 
         SELECT /* SHSNC */ 
            TABLE_OWNER OWNER,PARTITION_NAME PARTNAME, 
            NUM_ROWS NROWS, BLOCKS, AVG_SPACE AVGSPC,CHAIN_CNT CCNT, AVG_ROW_LEN ROWLEN, 
            SAMPLE_SIZE SSIZE,LAST_ANALYZED ANADATE 
         FROM ALL_TAB_PARTITIONS 
         WHERE UPPER(TABLE_OWNER)=NVL(UPPER('$3'),TABLE_OWNER)  AND TABLE_NAME=UPPER('$2');
         exit
EOF
     ;;
 
   istat)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col OWNER format a10
         col lkey format 999
         col dkey format 999 
         col lev format 99
         col anaday format a10
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */  
            TABLE_OWNER OWNER, INDEX_NAME, 
            BLEVEL LEV, LEAF_BLOCKS LBLKS,TRUNC(NUM_ROWS) NROWS,
            DISTINCT_KEYS DROWS, 
            CLUSTERING_FACTOR CLSFCT,SAMPLE_SIZE SSIZE, 
            TO_CHAR(LAST_ANALYZED,'YYYY/MM/DD') ANADAY, 
            PARTITIONED PAR 
         FROM ALL_INDEXES 
         WHERE UPPER(TABLE_OWNER)=NVL(UPPER('$3'),TABLE_OWNER)
           AND TABLE_NAME=UPPER('$2');
         exit
EOF
     ;;
 
   ipstat)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col OWNER format a10
         col lkey format 999
         col dkey format 999
         col lev format 99
         col anaday format a10
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */
            PARTITION_NAME,
            BLEVEL LEV, LEAF_BLOCKS LBLKS,TRUNC(NUM_ROWS) NROWS,
            DISTINCT_KEYS DROWS,
            CLUSTERING_FACTOR CLSFCT,SAMPLE_SIZE SSIZE,
            TO_CHAR(LAST_ANALYZED,'YYYY/MM/DD') ANADAY
         FROM ALL_IND_PARTITIONS
         WHERE UPPER(INDEX_OWNER)=NVL(UPPER('$3'),INDEX_OWNER)
           AND INDEX_NAME=UPPER('$2');
         exit
EOF
     ;;
 
   objsql)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col vers format 999
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ 
            HASH_VALUE, OPEN_VERSIONS VERS, 
            SORTS, EXECUTIONS EXECS,  
            DISK_READS READS, BUFFER_GETS GETS, 
            ROWS_PROCESSED ROWCNT
          FROM V\$SQL WHERE EXECUTIONS > 10 AND HASH_VALUE IN 
            (SELECT /*+ NL_SJ */ DISTINCT HASH_VALUE 
               FROM V\$SQL_PLAN WHERE OBJECT_NAME=UPPER('$2') 
               AND NVL(OBJECT_OWNER,'A')=UPPER(NVL('$3','A')));
         exit
EOF
     ;;
 
   longops)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col MESSAGE format a30
         col opname for a20
         col username for a20
         set pagesize 1000
         alter session set cursor_sharing=force;
         select opname,TIME_REMAINING REMAIN,
                ELAPSED_SECONDS ELAPSE,MESSAGE,
                SQL_ID,sid,username
         from v\$session_longops where TIME_REMAINING >0;
         exit
EOF
     ;;
 
   tran)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a12
         col rbs format a12
         col BLKS_RECS format a16
         col START_TIME format a17
         col LOGIO format 99999
         col PHY_IO FORMAT 99999
         COL CRGET FORMAT 99999
         COL CRMOD FORMAT 99999
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ /* RULE */   
             S.SID,S.SERIAL#,S.USERNAME, R.NAME RBS, 
             T.START_TIME,  
             to_char(T.USED_UBLK)||','||to_char(T.USED_UREC) BLKS_RECS ,
             T.LOG_IO LOGIO,T.PHY_IO PHYIO,T.CR_GET CRGET,T.CR_CHANGE CRMOD 
           FROM V\$TRANSACTION T, V\$SESSION S,V\$ROLLNAME R, 
                V\$ROLLSTAT RS
           WHERE T.SES_ADDR(+) = S.SADDR   
             AND T.XIDUSN = R.USN AND S.USERNAME IS NOT NULL  
             AND R.USN = RS.USN ;
         exit
EOF
     ;;
 
   depend)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ TYPE,REFERENCED_OWNER D_OWNER, 
               REFERENCED_NAME D_NAME,REFERENCED_TYPE D_TYPE, 
               REFERENCED_LINK_NAME DBLINK, DEPENDENCY_TYPE DEPEND
           FROM ALL_DEPENDENCIES 
           WHERE 
             UPPER(OWNER) = NVL(UPPER('$3'),OWNER) 
             AND NAME  = UPPER('$2');
         SELECT /* SHSNC */  REFERENCED_TYPE TYPE,OWNER R_OWNER,
                NAME R_NAME, TYPE R_TYPE,DEPENDENCY_TYPE DEPEND 
           FROM ALL_DEPENDENCIES 
           WHERE 
             UPPER(REFERENCED_OWNER) = NVL(UPPER('$3'),REFERENCED_OWNER) 
             AND REFERENCED_NAME  = UPPER('$2')
             AND REFERENCED_LINK_NAME IS NULL;
         exit
EOF
     ;;
 
   latch)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ NAME FROM V\$LATCHNAME WHERE LATCH#=TO_NUMBER('$2');
         exit
EOF
     ;;
 
   hold)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a16
         col MACHINE format a20
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ /*+ RULE */ 
             S.SID,S.SERIAL#,P.SPID,S.USERNAME, 
             S.MACHINE,S.STATUS
           FROM V\$PROCESS P, V\$SESSION S, V\$LOCKED_OBJECT O   
           WHERE P.ADDR = S.PADDR  AND O.SESSION_ID=S.SID    
             AND S.USERNAME IS NOT NULL 
             AND O.OBJECT_ID=TO_NUMBER('$2');
         exit
EOF
     ;;
 
   sort)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a12
         col MACHINE format a16
         col TABLESPACE format a10
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ /*+ ordered */  
           B.SID,B.SERIAL#,B.USERNAME,B.MACHINE,A.BLOCKS,A.TABLESPACE,
           A.SEGTYPE,A.SEGFILE# FILE#,A.SEGBLK# BLOCK#
           FROM V\$SORT_USAGE A,V\$SESSION B
           WHERE A.SESSION_ADDR = B.SADDR
          order by A.BLOCKS desc; 
         exit
EOF
     ;;
 
   desc)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col name format a30
         col nullable format a8
         col type format a30
         alter session set cursor_sharing=force;
         select /* SHSNC D5 */ 
           COLUMN_ID NO#,COLUMN_NAME NAME, 
           DECODE(NULLABLE,'N','NOT NULL','') NULLABLE, 
           (case  
              when data_type='CHAR' then data_type||'('||data_length||')' 
              when data_type='VARCHAR' then data_type||'('||data_length||')' 
              when data_type='VARCHAR2' then data_type||'('||data_length||')' 
              when data_type='NCHAR' then data_type||'('||data_length||')' 
              when data_type='NVARCHAR' then data_type||'('||data_length||')' 
              when data_type='NVARCHAR2' then data_type||'('||data_length||')' 
              when data_type='RAW' then data_type||'('||data_length||')' 
              when data_type='NUMBER' then 
                    ( 
                       case 
                          when data_scale is null and data_precision is null then 'NUMBER' 
                          when data_scale <> 0  then 'NUMBER('||NVL(DATA_PRECISION,38)||','||DATA_SCALE||')' 
                      else 'NUMBER('||NVL(DATA_PRECISION,38)||')' 
                       end 
                    ) 
              else
                 ( case 
                     when data_type_owner is not null then data_type_owner||'.'||data_type 
                                 else data_type 
                   end ) 
            end) TYPE 
            from all_tab_columns 
            where upper(owner)=UPPER(nvl('$3',owner)) AND TABLE_NAME=upper('$2') 
            order by 1;
         exit
EOF
     ;;
 
   segment)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a12
         col MACHINE format a16
         col TABLESPACE format a10
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ /*+ RULE */ 
            SEGMENT_TYPE,OWNER SEGMENT_OWNER,SEGMENT_NAME,  
                    TRUNC(SUM(BYTES)/1024/1024,1) SIZE_MB 
            FROM DBA_SEGMENTS WHERE OWNER NOT IN ('SYS','SYSTEM') 
            GROUP BY SEGMENT_TYPE,OWNER,SEGMENT_NAME 
            HAVING SUM(BYTES) > TO_NUMBER(NVL('$2','100')) * 1048576  
            ORDER BY 1,2,3,4 DESC;
         exit
EOF
     ;;
 
   seqlike)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col owner format a12
         col MAX_VALUE format 999999999999
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ SEQUENCE_OWNER OWNER,SEQUENCE_NAME, 
            MIN_VALUE LOW,MAX_VALUE HIGH,INCREMENT_BY STEP,CYCLE_FLAG CYC,
            ORDER_FLAG ORD,CACHE_SIZE CACHE,LAST_NUMBER CURVAL
           FROM ALL_SEQUENCES 
           WHERE ('$3' IS NULL OR UPPER(SEQUENCE_OWNER) = UPPER('$3')) 
             AND SEQUENCE_NAME LIKE UPPER('$2');
         exit
EOF
     ;;
 
   tabpart)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a12
         col MACHINE format a16
         col TABLESPACE format a10
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ PARTITION_POSITION NO#,PARTITION_NAME,TABLESPACE_NAME TS_NAME, 
            INITIAL_EXTENT/1024 INI_K, NEXT_EXTENT/1024 NEXT_K,PCT_INCREASE PCT, 
            FREELISTS FLS, FREELIST_GROUPS FLGS 
           FROM ALL_TAB_PARTITIONS 
           WHERE ('$3' IS NULL OR UPPER(TABLE_OWNER) = UPPER('$3')) 
             AND TABLE_NAME LIKE UPPER('$2') 
           ORDER BY 1; 
         exit
EOF
     ;;
 
   view)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col TYPE_NAME format a30
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ OWNER,VIEW_NAME, 
            DECODE(VIEW_TYPE_OWNER,NULL,NULL,VIEW_TYPE_OWNER||'.'||VIEW_TYPE) TYPE_NAME
           FROM ALL_VIEWS 
           WHERE ('$3' IS NULL OR UPPER(OWNER) = UPPER('$3')) 
             AND VIEW_NAME LIKE UPPER('$2') 
             AND OWNER NOT IN ('SYS','SYSTEM','CTXSYS','WMSYS');
         exit
EOF
     ;;
 
   param)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col NAME format a40
         COL VALUE FORMAT A40
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ NAME,ISDEFAULT,ISSES_MODIFIABLE SESMOD, 
           ISSYS_MODIFIABLE SYSMOD,VALUE 
           FROM V\$PARAMETER 
           WHERE NAME LIKE '%' || LOWER('$2') || '%' 
             AND NAME <> 'control_files' 
             and name <> 'rollback_segments';
         exit
EOF
     ;;
 
   _param)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col NAME format a40
         COL VALUE FORMAT A40
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ 
           P.KSPPINM NAME, V.KSPPSTVL VALUE  
         FROM SYS.X\$KSPPI P, SYS.X\$KSPPSV V 
         WHERE P.INDX = V.INDX  
           AND V.INST_ID = USERENV('Instance') 
           AND SUBSTR(P.KSPPINM,1,1)='_'
           AND ('$2' IS NULL OR P.KSPPINM LIKE '%'||LOWER('$2')||'%');
         exit
EOF
     ;;
 
   grant)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col GRANTEE format a12
         col owner   format a12
         col GRANTOR format a12
         col PRIVILEGE format a20
         COL VALUE FORMAT A40
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ * FROM DBA_TAB_PRIVS 
          WHERE (OWNER=NVL(UPPER('$3'),OWNER) or '$3' IS NULL) 
            AND TABLE_NAME LIKE UPPER('$2');
         exit
EOF
     ;;
 
   unusable)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col GRANTEE format a12
         col owner   format a12
         col GRANTOR format a12
         col PRIVILEGE format a20
         COL VALUE FORMAT A40
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ 
           'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD ONLINE;' UNUSABLE_INDEXES 
         FROM ALL_INDEXES 
         WHERE (TABLE_OWNER=UPPER('$2') OR '$2' IS NULL) AND STATUS='UNUSABLE' 
         UNION ALL 
         SELECT 'ALTER INDEX '||IP.INDEX_OWNER||'.'||IP.INDEX_NAME||' REBUILD PARTITION ' 
                ||IP.PARTITION_NAME||' ONLINE;' 
         FROM ALL_IND_PARTITIONS IP, ALL_INDEXES I 
         WHERE IP.INDEX_OWNER=I.OWNER AND IP.INDEX_NAME=I.INDEX_NAME 
           AND (I.TABLE_OWNER=UPPER('$2') OR '$2' IS NULL) AND IP.STATUS='UNUSABLE' 
         UNION ALL 
         SELECT 'ALTER INDEX '||IP.INDEX_OWNER||'.'||IP.INDEX_NAME||' REBUILD SUBPARTITION ' 
                ||IP.PARTITION_NAME||' ONLINE;' 
         FROM ALL_IND_SUBPARTITIONS IP, ALL_INDEXES I 
         WHERE IP.INDEX_OWNER=I.OWNER AND IP.INDEX_NAME=I.INDEX_NAME 
           AND (I.TABLE_OWNER=UPPER('$2') OR '$2' IS NULL) AND IP.STATUS='UNUSABLE';
         exit
EOF
     ;;
 
   invalid)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 150
         col owner format a12
         col object_name format a30
         col created format a20
         col last_ddl_time format a19
         alter session set cursor_sharing=force;
         SELECT /* SHSNC */ 
                OBJECT_ID, OWNER,OBJECT_NAME,OBJECT_TYPE, 
           to_char(created,'yy-mm-dd hh24:mi:ss') created, 
           to_char(LAST_DDL_TIME,'yy-mm-dd hh24:mi:ss') last_ddl_time 
         FROM DBA_OBJECTS 
         WHERE STATUS='INVALID' AND ('$2' IS NULL OR OWNER=UPPER('$2'));
         exit
EOF
     ;;
 
     ddl)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set long 49000
         set longc 9999
         set line 150
         set pagesize 10000
         alter session set cursor_sharing=force;
         SELECT   dbms_metadata.get_ddl(upper('$3'),upper('$4'),upper('$2')) from dual;
         exit
EOF
     ;;
     
     dx)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 400;
          col "waiter" format a8;
          col "w_Machine" format a15;
          col "h_HOLDER" format a8;
          col "h_Machine" format a8;
          SELECT s1.username             waiter,
                 s1.machine              w_Machine,
                 w.sid                   w_sid,
                 s1.serial#              w_serial#,
                 s1.SQL_ID               w_sql_id,              
                 P1.spid                 w_PID,
                 S1.INST_ID              w_NSTANCE,
                 s2.username             h_HOLDER,
                 s2.machine              h_Machine,
                 h.sid                   h_sid, 
                 s2.serial#              h_serial#,
                 s2.sql_id               h_spid,
                 p2.spid                 h_PID,
                 S2.INST_ID              h_INSTANCE,
                 S2.PROCESS              h_process
          FROM   gv\$process P1,    gv\$process P2,
                 gv\$session S1,    gv\$session S2,
                 gv\$lock w,        gv\$lock h
          WHERE
            (((h.LMODE != 0) and (h.LMODE != 1)
            and ((h.REQUEST = 0) or (h.REQUEST = 1)))
            and  (((w.LMODE= 1) or (w.LMODE = 0))
            and ((w.REQUEST != 1) and (w.REQUEST != 0))))
            and  w.type =  h.type
            and  w.id1  =  h.id1
            and  w.id2  =  h.id2
            and  w.sid     !=  h.sid
            and  w.sid       = S1.sid
            and  h.sid       = S2.sid
            and  S1.EVENT  ='enq: DX - contention'
            AND    S1.paddr           = P1.addr
            AND    S2.paddr           = P2.addr
            order by waiter,h.CTIME;
            exit
EOF
     ;;
     
       
     hcost) 
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 300 pagesize 1000;
          col "program" format a30;
          col "event" format a30;
          col "osuser" format a15;
          col "username" format a15;
          select /*+ rule */ distinct sess.username,nvl(decode(nvl(sess.module,sess.program),'SQL*Plus',sess.program,sess.module),sess.machine||':'||sess.process) program,sess.sid,sess.sql_id,sess.osuser,p.spid,sess.event,plan.cost from v\$session sess,v\$sql_plan plan,v\$process p where sess.sql_id=plan.sql_id and plan.id=0 and cost>$2  and sess.status='ACTIVE' and p.addr=sess.paddr order by cost desc;
     exit
EOF
     ;;
     
     get_kill_sh)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 120;
         set pages 9999;
     select 'ps -ef|grep '||to_char(spid)||'|grep LOCAL=NO|awk ''{print " -9 "\$2}''|xargs kill' kill_sh 
                from v\$process p,v\$session s
                where s.paddr=p.addr
                and s.sql_id='$2';
     exit
EOF
     ;;
     
    hsql)
     sqlplus -s "$SQLPLUS_CMD" << EOF
                col username for a10
                col program for a50
                col event for a30
                set line 300 pagesize 1000
                select s.username,s.program,s.sql_id,s.event,p.spid,sql.cpu_time/1000000/decode(EXECUTIONS,0,1,EXECUTIONS) cpu,sql.BUFFER_GETS/decode(EXECUTIONS,0,1,EXECUTIONS) buff
                from  v\$sql sql,v\$session s,v\$process p
                where s.sql_id=sql.sql_id
                and s.status='ACTIVE'
                and WAIT_CLASS#<>6
                and s.paddr=p.addr
                order by 6 desc;
     exit
EOF
     ;;
     
    frag)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     set line 300 pagesize 1000
                set pagesize 300
                col table_name for a35
                col owner for a6
                col tab_size for 999999.999999
                col safe_space for 999999.999999
                select owner,table_name,blocks*8/1024 TAB_SIZE,(AVG_ROW_LEN*NUM_ROWS+INI_TRANS*24)/(BLOCKS*8*1024)*100 used_pct,((BLOCKS*8*1024)-(AVG_ROW_LEN*NUM_ROWS+INI_TRANS*24))/1024/1024*0.9 safe_space 
                from dba_tables
                where (owner like '__YY' or owner like '__ZW' or owner='COMMON')
                AND blocks>1024*10 
                and (AVG_ROW_LEN*NUM_ROWS+INI_TRANS*24)/(BLOCKS*8*1024)*100<50
                order by 4;     
     exit
EOF
     ;;
     
     tsql)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 300;
         set pagesize 300;
         col module for a30;
         col PARSING_SCHEMA_NAME for a10;
        select to_char(a.begin_time,'yyyymmdd hh24:mi'),to_char(a.end_time,'yyyymmdd hh24:mi'),a.INSTANCE_NUMBER,a.PARSING_SCHEMA_NAME,a.MODULE,a.SQL_ID,a.BUFFER_GETS_DELTA,a.CPU_TIME_DELTA/b.VALUE*100 cpu_pct
                                from (
                                select * from(
                                select ss.snap_id,sn.BEGIN_INTERVAL_TIME begin_time,sn.END_INTERVAL_TIME end_time,sn.INSTANCE_NUMBER,PARSING_SCHEMA_NAME,MODULE,SQL_ID,BUFFER_GETS_DELTA,CPU_TIME_DELTA,
                                RANK() OVER (PARTITION BY ss.snap_id,sn.INSTANCE_NUMBER ORDER BY CPU_TIME_DELTA DESC)rank
                                from DBA_HIST_SQLSTAT ss,DBA_HIST_SNAPSHOT sn
                                where sn.SNAP_ID=ss.snap_id
                                and sn.BEGIN_INTERVAL_TIME between sysdate-$2/24 and sysdate
                                and ss.INSTANCE_NUMBER=sn.INSTANCE_NUMBER)
                                where rank<6) a,DBA_HIST_SYSSTAT b
                                where a.snap_id=b.snap_id
                                and a.INSTANCE_NUMBER=b.INSTANCE_NUMBER
                                and b.STAT_ID=3649082374
                                order by 1,3 asc,8 desc;
     exit
EOF
     ;;
          
free_ext) 
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 200 pagesize 1000;
                select t.TABLESPACE_NAME,sum(D.bytes)/1024/1024/1024 "表空间大小(G)",t.free "最大连续段大小(G)"
                from (
                select TABLESPACE_NAME,max(free_space)free
                from (
                select f.TABLESPACE_NAME,f.FILE_ID,BLOCK_ID,sum(f.BYTES)/1024/1024/1024 free_space
                from dba_free_space f,dba_tablespaces t
                where t.TABLESPACE_NAME =f.TABLESPACE_NAME
                and t.ALLOCATION_TYPE='SYSTEM'
                and t.contents<>'UNDO'
                and t.TABLESPACE_NAME not in('SYSAUX','SYSTEM','USERS','TIVOLIORTS')
                group by f.TABLESPACE_NAME,f.FILE_ID,BLOCK_ID
                )t
                group by t.TABLESPACE_NAME)t,dba_data_files d
                where t.tablespace_name=d.tablespace_name
                group by t.TABLESPACE_NAME,t.free 
                having t.free<2;
     exit
EOF
     ;; 
         
       parttab) 
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 200;
          COL "owner" format a10
          col "column_name" format a10
          col "object" format a10
          col "partitioning_type" format a20
          col "data_type" format a15
          SELECT C.*,D.DATA_TYPE FROM (select a.owner, a.name, a.column_name,a.OBJECT_TYPE,b.PARTITIONING_TYPE from DBA_PART_KEY_COLUMNS a, DBA_PART_TABLES b where a.owner=b.owner and a.NAME=b.TABLE_NAME) C ,DBA_TAB_COLS D WHERE C.owner=D.OWNER AND C.name=D.TABLE_NAME and c.column_name=d.COLUMN_NAME and UPPER(C.OWNER)=UPPER('$2')  AND D.TABLE_NAME=UPPER('$3'); 
     exit
EOF
     ;;
 
 sqltuning)
   if [ $2 = ]; then
     echo "you don't input the seconde variable sql_id,please input sql_id in \$sql"
     exit    
   else 
     sqlplus / as sysdba <<EOF
       SET LONG 10000000 LONGCHUNKSIZE 1000000 LINESIZE 150 pagesize 0 serveroutput on SIZE 1000000    
       DECLARE
                 my_task_name VARCHAR2(30);
                 v_sqlid      VARCHAR2(50);
       BEGIN
                 v_sqlid:='$2';
                 my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK
                                 (sql_id=>v_sqlid,
                                  scope => 'comprehensive',
                                  time_limit=>60,
                                  task_name=>'my_sql_tuning',
                                  description => 'Tuning Task');
                 DBMS_SQLTUNE.EXECUTE_TUNING_TASK('my_sql_tuning');
      END;
      /
                 SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('my_sql_tuning') FROM dual;
                 EXEC DBMS_SQLTUNE.DROP_TUNING_TASK('my_sql_tuning');  
                 EXIT;
EOF
     fi
;;
 
vio)
    interval=$2
    count=$3
    
    Plat=`uname`
    case $Plat in
    "SunOS") 
        printf "%s\t%s\t%s\t%s\n" "r/s" "w/s" "kr/s" "kw/s"
        sar -d $interval $count|awk 'BEGIN {i=0;j=0;n=0;m=0}
                {if ($1=="tty" && NR != 1) 
                {printf "%s\t%s\t%s\t%s\n",i,j,n,m;i=0;j=0;n=0;m=0}
                else {i=i+$1;j=j+$2;n=n+$3;m=m+$4}}'
        ;;
    "HP-UX")
        printf "%s\t%s\t%s\n" `date +%T` "r+w/s" "k(r+w)/s"
        sar -d $interval $count|grep -v disk|awk 'BEGIN {i=0;j=0}
                {if ($1 ~ ":" && i != 0 && NR != 1)
                {printf "%s\t%s\t%s\n",$1,i,j;i=$5;j=$6/2}
                else {i=i+$4;j=j+$5/2}}'
        ;;
    "AIX")
        printf "%s\t%s\t%s\t%s\n" "time stamp" "io/s" "kr/s" "kw/s"
        iostat -T $interval $count |egrep 'hdisk|tty'| awk -v Int=$interval 'BEGIN {io=0;kr=0;kw=0} {if ($1=="tty:" && NR != 1)  {akr=kr/Int;akw=kw/Int;printf "%s\t%s\t%s\t%s\n",time,io,akr,akw;io=0;kr=0;kw=0} else {io=io+$3;kr=kr+$5;kw=kw+$6;time=$7}}'
        ;;
    esac
;;
 
 hang)
    lnodesFound=0
    lsnodes > /dev/null 2>&1
    if [ $? = 0 ]; then
        lnodesFound=1
    else
        olsnodes > /dev/null 2>&1
        if [ $? = 0 ]; then
            lnodesFound=1 
        fi
    fi 
    
    if [ $lnodesFound = 1 ]; then    
        sqlplus -s "$SQLPLUS_CMD" << EOF
        set echo off
        set feedback off
        set arraysize 4
        set pagesize 0
        set pause off
        set linesize 200
        set verify off
        set head off
        spool /tmp/hanganalyze.tmp
        oradebug setmypid
        oradebug unlimit
        oradebug -g all hanganalyze 3
        !sleep 60
        oradebug -g all hanganalyze 3
        !sleep 60
        oradebug -g all hanganalyze 3
        spool off
        exit
EOF
    else    
        sqlplus -s "$SQLPLUS_CMD" << EOF
        set echo off
        set feedback off
        set arraysize 4
        set pagesize 0
        set pause off
        set linesize 200
        set verify off
        set head off
        spool /tmp/hanganalyze.tmp
        oradebug setmypid
        oradebug unlimit
        oradebug hanganalyze 3
        !sleep 60
        oradebug hanganalyze 3
        !sleep 60
        oradebug hanganalyze 3
        spool off
        exit
EOF
    fi
;;
 
 ksql)
  ct
  sqlplus -s "$SQLPLUS_CMD" << EOF
  set line 300 pagesize 1000
  col username for a15
  col program for a40
  col event for a30
  select sid,serial#,username,program,sql_id,event from v\$session where sql_id='$2';
  select 'alter system kill session '''||sid||','||serial#||''' immediate;' from v\$session where sql_id='$2';
  spool $temp_cmd_file
  set heading off
  col kill_sh for a90
  select 'ps -ef |grep '||to_char(spid)||'|grep LOCAL=NO|awk ''{print" -9 "\$2}''|xargs kill' kill_sh from v\$process p,v\$session s
 where s.paddr=p.addr and type='USER' and s.sql_id='$2';
 spool off
 exit
EOF
  echo "Can you confirm?[y/n]"
  read answer
  if [ ${answer}"TEST" != "yTEST" ]
   then
    rm $temp_cmd_file
    exit;
  fi 
  cat $temp_cmd_file | while read line
  do
  echo $line
  eval $line
  done
  rm $temp_cmd_file
  ;;
 
unlocku)
  echo "alter user $2 account unlock;"
  echo "Can you confirm?[y/n]"
  read answer
  if [ ${answer}"TEST" != "yTEST" ]
   then
    exit;
  fi 
  sqlplus -s "$SQLPLUS_CMD" << EOF
   alter user $2 account unlock;
   exit
EOF
  ;;
 
ant)
  echo "exec DBMS_STATS.GATHER_TABLE_STATS(ownname=>'$2',tabname=>'$3',estimate_percent=>10,no_invalidate=>false,cascade=>true,degree => 10);"
  echo "Can you confirm?[y/n]"
  read answer
  if [ ${answer}"TEST" != "yTEST" ]
   then
    exit;
  fi
  sqlplus -s "$SQLPLUS_CMD" << EOF
   exec DBMS_STATS.GATHER_TABLE_STATS(ownname=>'$2',tabname=>'$3',estimate_percent=>10,no_invalidate=>false,cascade=>true,degree => 10);
   exit
EOF
  ;;
 
chpw)
  echo "alter user $2 identified by $3;"
  echo "Can you confirm?[y/n]"
  read answer
  if [ ${answer}"TEST" != "yTEST" ]
   then
    exit;
  fi
  sqlplus -s "$SQLPLUS_CMD" << EOF
   alter user $2 identified by $3;
   exit
EOF
  ;;
  
  
refplan)
  echo "grant select on $2.$3 to system;"
  echo "Can you confirm?[y/n]"
  read answer
  if [ ${answer}"TEST" != "yTEST" ]
   then
    exit;
  fi
  sqlplus -s "$SQLPLUS_CMD" << EOF
   grant select on $2.$3 to system;
   exit
EOF
  ;;
 
tcsql)
sqlplus -s "$SQLPLUS_CMD" << EOF
set linesize 250 pagesize 30000
col username for a15
col event for a35
col program for a20 truncate
col cpu_p for 99.99
select ta.*,round(ta.cpu_time/tb.total_cpu * 100,1) cpu_usage from
(select s.username,s.program,s.event,s.sql_id,sum(trunc(m.CPU)) CPU_TIME,count(*) sum
        --,sum(m.PHYSICAL_READS) P_READ,sum(LOGICAL_READS) L_READ
  from v\$sessmetric m ,v\$session s
 where ( m.PHYSICAL_READS >100
       or m.CPU>100
       or m.LOGICAL_READS >100)
       and m.SESSION_ID = s.SID
       and m.SESSION_SERIAL_NUM = s.SERIAL#
       and s.status = 'ACTIVE'
       and username is not null
 group by s.username,s.program,s.event,s.sql_id
 order by 5 desc) ta,(select sum(cpu) total_cpu from v\$sessmetric) tb
where rownum < 11;
   exit
EOF
  ;;
 
esess)
sqlplus -s "$SQLPLUS_CMD" << EOF
set linesize 300
col sid format 99999
col sql_id for a15
col program for a18
col username format a10
col osuser format a10
col schemaname format a10
col machine format a15
col client_info format a13
col wait_class format a13
col status format a8
col blocking_session format 99999
select sid,
       paddr,
       sql_id,
       to_char(logon_time, 'yyyy-mm-dd hh24:mi:ss') as l_time,
       program,
       machine,
       osuser,
       username,
       schemaname,
       client_info,
       wait_class,
       status,
       blocking_session
  from v\$session
 where  EVENT#=$2
 and schemaname <> 'SYS';
exit
EOF
  ;; 
 
   *)
     echo
     echo "Usage:";
     echo "  ora keyword [value1 [value2]] ";
     echo "  -----------------------------------------------------------------";
     echo "  si                          -- Login as OS User";
     echo "  ke         [event#]         -- kill event"; 
     echo "  log                         -- tail alert*.log";
     echo "  undo                        -- v\$undostat";
     echo "  hplan      [sql_id]         -- dba_hist_sql_plan";
     echo "  highpara                    -- get hight pararllel module";    
     echo "  active                      -- Get Active Session";
     echo "  size       tabname [owner]  -- Get Size of tables/indexes";
     echo "  idxdesc    tabname owner    -- Display index structure";
     echo "  tsfree     [tsname]         -- Get Tablespace Usage";
     echo "  tempfree   [tsname]         -- Get TempTablespace Usage";
     echo "  tablespace tsname           -- Tablespace Information";
     echo "  datafile   tsname           -- List data files by tablespace";
     echo "  tempfile   tsname           -- List tempdata files by tablespace";
     echo "  sqltext    SQL_ID           -- Get SQL Text by hash value";
     echo "  plan       SQL_ID           -- Get Execute Plan by SQL_ID";
     echo "  lock       [sid]            -- Get lock information by sid";
     echo "  lockwait                    -- Get lock requestor/blocker";
     echo "  objlike    pattern [owner]  -- Get object by name pattern";
     echo "  tablike    pattern [owner]  -- Get table by name pattern";
     echo "  tstat      tabname owner    -- Get table statistics";
     echo "  istat      tabname owner    -- Get index statistics";
     echo "  ipstat     indname owner    -- Get index partition statistics";
     echo "  objsql     objname owner    -- Get SQLs by object name";
     echo "  longops                     -- Get long run query";
     echo "  tran                        -- Get all the transactions";
     echo "  depend     objname [owner]  -- Get dependency information";
     echo "  latch      latch#           -- Get latch name by latch id";
     echo "  hold       objectid         -- Who have lock on given object?";
     echo "  sort                        -- Who is running sort operation?";
     echo "  desc       tabname [owner]  -- Describe Table Structure";
     echo "  segment    [size]           -- Segment large than given size";
     echo "  seqlike    pattern [owner]  -- Get sequence by name pattern";
     echo "  tabpart    tabname [owner]  -- List table partitions";
     echo "  view       pattern [owner]  -- List view by name pattern";
     echo "  param      pattern          -- List Oracle parameters";
     echo "  _param     pattern          -- List Oracle hidden parameters";
     echo "  grant      objname [owner]  -- Get grant information";
     echo "  unusable   [owner]          -- List unusable indexes";
     echo "  invalid    [owner]          -- List invalid objects";
     echo "  ddl        owner object_type name ---get the create object sql";
     echo "  event                       -- List all wait event";
     echo "  dx                          -- List all dxlock wait";
     echo "  hcost  cost_value           -- Get session info of cost more than cost_value";
     echo "  get_kill_sh sql_id username -- Get kill OS spid of sql_id and username";
     echo "  free_ext                    -- Get the max contiguous free space of tablespace";
     echo "  tsql hours                  -- Get top5 sql for the last n hours";
     echo "  frag                        -- Get fragment table";
     echo "  parttab owner tabname       -- Get partition_table column";
     echo "  res cpu   n                 -- get top top_value process of consume by cpu";
     echo "  res io    n                 -- get top top_value process of consume by io";
     echo "  res buff  n                 -- get top top_value process of consume by io";
     echo "  res mem   v                 -- get process of consume pga_memery than mem_value v";
     echo "  res drgee v                 -- get process of parallel than degree_value v";
     echo "  res all   n                 -- get top top_value process of sum consume by resource";
     echo "  sqltuning sql_id            -- get sql tuning suggestion";
     echo "  sess  SID                   -- get session infomation ";
     echo "  vio   interval count        -- get disk io sumary stat";
     echo "  asmfree                     -- Get ASM Usage";
     echo "  hang                        -- excute hanganalyze (level 3)";
     echo "  ksql                        -- Kill session by sql id";
     echo "  unlocku  username           -- unlock user";
     echo "  ant      owner tabname      -- Analyze table";
     echo "  chpw     username password  -- Change password";
     echo "  refplan  owner tabname      -- Refresh plan";
     echo "  tcsql                       -- Top sql by CPU usage ";
     echo "  esess event#                -- get session infomation by event#";
     echo "  ----------------------------------------------------------------";
     echo
     ;;
esac 