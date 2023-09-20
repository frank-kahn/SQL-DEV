#!/bin/sh
#基于Oracle SQLplus的工具
#使用指南：
#orz keyword [value1 [value2]]
#eg:以当前os用户连接Oracle数据库
#./orz.sh si



if [ "$LOGNAME" = "sys" ]; then
   SQLPLUS_CMD="/ as sysdba";
else
   SQLPLUS_CMD="/ as sysdba";
fi

case $1 in 
   si)
     if [ "$LOGNAME" = "sys" ]; then
        sqlplus "/ as sysdba"
     else
        sqlplus "/ as sysdba"
     fi
     ;;
   active)
         sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 160
         col sid format 9999
	 col spid for a10
         col s# format 99999
         col username format a10
         col event format a30
         col machine format a12
         col program for a15
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
             S.program,
             S.EVENT,
             S.P1 || '/' || S.P2 || '/' || S.P3 P123,
             S.WAIT_TIME WT,
			 s.last_call_et,
			 s.status,
			 s.blocking_instance || ':' || s.blocking_session blocking,
             NVL(SQL_ID, S.PREV_SQL_ID) SQL_ID
              FROM V\$PROCESS P, V\$SESSION S
             WHERE P.ADDR = S.PADDR
               AND S.STATUS = 'ACTIVE'
               AND P.BACKGROUND IS NULL;
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
       order by 1;
               exit
EOF
     ;;
 event)
     sqlplus -s "$SQLPLUS_CMD" << EOF
     set linesize 150
     select event,count(*) from v\$session group by event;
               exit
EOF
     ;;     
   size)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col owner format a10
         col segment_name for a30
         alter session set cursor_sharing=force;
         SELECT  /*+ shsnc */ OWNER,SEGMENT_NAME, SEGMENT_TYPE, SUM(BYTES)/1048576 SIZE_MB, 
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
     SELECT D.TABLESPACE_NAME,SPACE "SUM_SPACE(M)",BLOCKS SUM_BLOCKS,SPACE - NVL(FREE_SPACE, 0) "USED_SPACE(M)",
            ROUND((1 - NVL(FREE_SPACE, 0) / SPACE) * 100, 2) "USED_RATE(%)", FREE_SPACE "FREE_SPACE(M)"
             FROM (SELECT TABLESPACE_NAME, ROUND(SUM(BYTES) / (1024 * 1024), 2) SPACE, SUM(BLOCKS) BLOCKS 
               FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) D,
                              (SELECT TABLESPACE_NAME, ROUND(SUM(BYTES) / (1024 * 1024), 2) FREE_SPACE 
               FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) F
      WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)
      ORDER BY  "USED_RATE(%)" DESC; 
         exit
EOF
      ;;
   tablespace)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         alter session set cursor_sharing=force;
         select 
            TABLESPACE_NAME TS_NAME,INITIAL_EXTENT INI_EXT,NEXT_EXTENT NXT_EXT,
            STATUS,CONTENTS, EXTENT_MANAGEMENT EXT_MGR,ALLOCATION_TYPE ALLOC_TYPE 
         FROM DBA_TABLESPACES ORDER BY TABLESPACE_NAME;
         exit
EOF
      ;;
   datafile)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col name format a60
         col file# format 9999
         col size_mb format 99999
         alter session set cursor_sharing=force;
         select  /*+ RULE */
            f.file#, F.NAME, TRUNC(f.BYTES/1048576,2) SIZE_MB , f.CREATION_TIME, status
         FROM V\$DATAFILE F,V\$TABLESPACE T
         WHERE F.ts#=T.ts# AND T.NAME = NVL(UPPER('$2'),'SYSTEM')
         order by f.CREATION_TIME;
         exit
EOF
      ;;
   lastdatafile)
     sqlplus -s "$SQLPLUS_CMD" << EOF
	set lin 200
	set pages 200
	col tablespace_name for a25
	col datafile_name for a60
        col creation_time for a25
	alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
        select * from (select /*+ RULE */ T2.NAME as tablespace_name,t.name as datafile_name,T.CREATION_TIME,t.bytes/1024/1024 as M from v\$datafile t,v\$tablespace t2 where t.ts#= t2.ts# order by 3 desc) where rownum<10;
        exit
EOF

     ;;
   sqltext)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         alter session set cursor_sharing=force;
         SELECT  SQL_TEXT FROM V\$SQLTEXT 
          WHERE SQL_ID = to_char('$2')
          ORDER BY PIECE;
         exit
EOF
    ;;
   allsqltext)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         alter session set cursor_sharing=force;
	 set lin 180
	set pages 999
	col sid for 999999
	col serial# for 99999
	col program for a15
	col machine for a15
	col sql_id for a15
	col sql_text for a50
       col username for a10
  SELECT t1.sid,
         t1.serial#,
         t1.username,
         t1.program,
         t1.machine,
         t1.sql_id,
         t2.sql_text
    FROM v\$session t1, v\$sql t2
   WHERE t1.sql_id = t2.sql_id
   and t1.status='ACTIVE';         
         exit
EOF
   ;;
   plan)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         alter session set cursor_sharing=force;
         set linesize 150
         SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(to_char('$2'),NULL),'advanced');
         exit
EOF
     ;;
   lock)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col type format a12
         col hold format a12
         col request format a12
         col BLOCK_OTHERS format a16
         alter session set cursor_sharing=force;
         select  /*+ RULE */ 
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
   showblock)
     sqlplus -s "$SQLPLUS_CMD" << EOF
        set linesize 140
	col sess for a40
        alter session set cursor_sharing=force;
        select /*+ RULE */ decode(request, 0, 'Holder:', ' --Waiter:') || s.inst_id || ':' ||
       s.sid || ',' || s.serial# as sess,
       l.id1,
       l.id2,
       l.lmode,
       l.request,
       l.type,
       l.ctime,
       s.sql_id,
       s.event,
       s.last_call_et
  from gv\$lock l, gv\$session s
 where (id1, id2, l.type) in
       (select id1, id2, type from gv\$lock where request > 0)
   and l.sid = s.sid
   and l.inst_id = s.inst_id order by id1,ctime desc,request;
         exit
EOF
     ;;
   lockwait)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 180
         col HOLD_SID format 99999
         col WAIT_SID format 99999
         col type format a20
         col hold format a12
         col request format a12
         alter session set cursor_sharing=force;
         SELECT  /*+ ORDERED USE_HASH(H,R) */ 
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
         SELECT  OBJECT_TYPE TYPE,OBJECT_ID ID,OWNER,OBJECT_NAME, 
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
         SELECT  OBJECT_ID ID,OWNER,OBJECT_NAME,
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
         set linesize 120
         col owner format a10
         col partname format a30
         col INIEXT format 99999
         col nxtext format 99999
         col avgspc format 99999
         col ccnt format 999
         col rowlen format 9999
         col ssize format 9999
         alter session set cursor_sharing=force;
         SELECT  
            OWNER,NULL PARTNAME, 
            NUM_ROWS NROWS, BLOCKS, AVG_SPACE AVGSPC,CHAIN_CNT CCNT, AVG_ROW_LEN ROWLEN, 
            SAMPLE_SIZE SSIZE,LAST_ANALYZED ANADATE 
         FROM ALL_TABLES 
         WHERE UPPER(OWNER)=NVL(UPPER('$3'),OWNER)  AND TABLE_NAME=UPPER('$2') 
         UNION ALL 
         SELECT  
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
         SELECT   
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
         SELECT 
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
         SELECT  
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
         SELECT  /* RULE */   
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
         SELECT  TYPE,REFERENCED_OWNER D_OWNER, 
               REFERENCED_NAME D_NAME,REFERENCED_TYPE D_TYPE, 
               REFERENCED_LINK_NAME DBLINK, DEPENDENCY_TYPE DEPEND
           FROM ALL_DEPENDENCIES 
           WHERE 
             UPPER(OWNER) = NVL(UPPER('$3'),OWNER) 
             AND NAME  = UPPER('$2');
         SELECT   REFERENCED_TYPE TYPE,OWNER R_OWNER,
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
         SELECT  NAME FROM V\$LATCHNAME WHERE LATCH#=TO_NUMBER('$2');
         exit
EOF
     ;;
   hold)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set linesize 120
         col USERNAME format a16
         col MACHINE format a20
         alter session set cursor_sharing=force;
         SELECT  /*+ RULE */ 
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
         SELECT  /*+ ordered */  
           B.SID,B.SERIAL#,B.USERNAME,B.MACHINE,A.BLOCKS,A.TABLESPACE,
           A.SEGTYPE,A.SEGFILE# FILE#,A.SEGBLK# BLOCK#
           FROM V\$SORT_USAGE A,V\$SESSION B
           WHERE A.SESSION_ADDR = B.SADDR; 
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
         select  
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
         SELECT  /*+ RULE */ 
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
         SELECT  SEQUENCE_OWNER OWNER,SEQUENCE_NAME, 
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
         SELECT  PARTITION_POSITION NO#,PARTITION_NAME,TABLESPACE_NAME TS_NAME, 
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
         SELECT  OWNER,VIEW_NAME, 
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
         SELECT  NAME,ISDEFAULT,ISSES_MODIFIABLE SESMOD, 
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
         SELECT  
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
         SELECT  * FROM DBA_TAB_PRIVS 
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
         SELECT  
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
         set linesize 120
         col owner format a12
         col object_name format a30
         col created format a10
         col last_ddl_time format a19
         alter session set cursor_sharing=force;
         SELECT  
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
         set long 9000
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
         set line 300;
          col "program" format a50;
          col "event" format a30
          col "username" format a15;
          select distinct sess.username,nvl(decode(nvl(sess.module,sess.program),'SQL*Plus',sess.program,sess.module),sess.machine||':'||sess.process) program,sess.sql_id,p.spid,sess.event,plan.cost from v\$session sess,v\$sql_plan plan,v\$process p where sess.sql_id=plan.sql_id and plan.id=0 and cost>$2 and sess.status='ACTIVE' and p.addr=sess.paddr order by cost desc;
     exit
EOF
     ;;
       get_kill_sh)
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 120;
          select 'ps -ef|grep '||to_char(spid)||'|grep LOCAL=NO|awk ''{print " -9 "\$2}''|xargs kill' kill_sh from v\$process p where exists (select 1 from v\$session where sql_id='$2' and username='$3' and paddr=p.addr);
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
     show_space) 
     sqlplus -s "$SQLPLUS_CMD" << EOF
         set line 200;
	 set serveroutput on
	 exec show_space(upper('$2'),upper('$3'),upper('$4'),upper('$5'),upper('$6'),upper('$7'))
     exit
EOF
     ;;

   *)
     echo
     echo "Usage:";
     echo "  orz keyword [value1 [value2]] ";
     echo "  -----------------------------------------------------------------";
     echo "  si                          -- Login as OS User";
     echo "  highpara                    -- get hight pararllel module";    
     echo "  active                      -- Get Active Session";
     echo "  size       tabname [owner]  -- Get Size of tables/indexes";
     echo "  idxdesc    tabname owner    -- Display index structure";
     echo "  tsfree     [tsname]         -- Get Tablespace Usage";
     echo "  tablespace tsname           -- Tablespace Information";
     echo "  datafile   tsname           -- List data files by tablespace";
     echo "  lastdatafile                -- List last ten data files by adding time";
     echo "  sqltext    SQL_ID           -- Get SQL Text by hash value";
     echo "  allsqltext                  -- Get All SQL Text ";
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
     echo "  parttab owner tabname       -- Get partition_table column";
     echo "  ----------------------------------------------------------------";
     echo
     ;;
esac
