-- 查看锁等待
set line 1000
col oracle_username for a20
col object_name for a20
col locked_modefor 99
select sess.sid, 
    sess.serial#, 
    lo.oracle_username, 
    lo.os_user_name, 
    ao.object_name, 
    lo.locked_mode 
    from v$locked_object lo, 
    dba_objects ao, 
    v$session sess 
where ao.object_id = lo.object_id and lo.session_id = sess.sid; 

-- 查询SQL语句
select * from v$session t1, v$locked_object t2 where t1.sid = t2.SESSION_ID; 

SELECT DISTINCT  
          s1.username  
       || '@'  
       || s1.machine  
       || ' ( INST='  
       || s1.inst_id  
       || ' SID='  
       || s1.sid  
       || ' Serail#='  
       || s1.serial#  
       || ' ) IS BLOCKING '  
       || s2.username  
       || '@'  
       || s2.machine  
       || ' ( INST='  
       || s2.inst_id  
       || ' SID='  
       || s2.sid  
       || ' Serial#='  
       || s2.serial#  
       || ' ) '  
          AS blocking_status  
  FROM gv$lock l1,  
       gv$session s1,  
       gv$lock l2,  
       gv$session s2 ,
       dba_objects ao,
       v$locked_object lo
 WHERE     s1.sid = l1.sid  
       AND s2.sid = l2.sid  
       AND s1.inst_id = l1.inst_id  
       AND s2.inst_id = l2.inst_id  
       AND l1.block > 0  
       AND l2.request > 0  
       AND l1.id1 = l2.id1  
       AND l1.id2 = l2.id2
       and ao.object_id = lo.object_id  and ao.object_name=upper('test')
       ; 

set line 1000
col 
SELECT /*+ rule */ s.username,
decode(l.type,'TM','TABLE LOCK',
'TX','ROW LOCK',
NULL) LOCK_LEVEL,
o.owner,o.object_name,o.object_type,
s.sid,s.serial#,s.terminal,s.machine,s.program,s.osuser
FROM v$session s,v$lock l,dba_objects o
WHERE l.sid = s.sid
AND l.id1 = o.object_id(+)
AND s.username is NOT Null;

set line 1000
col object_name for  a40
select sess.sid, 
    sess.serial#, 
    lo.oracle_username, 
    lo.os_user_name, 
    ao.object_name, 
    lo.locked_mode 
    from v$locked_object lo, 
    dba_objects ao, 
    v$session sess 
where ao.object_id = lo.object_id and lo.session_id = sess.sid and ao.object_name=upper('test'); 

SELECT 
C.SID
FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, SYS.GV_$SESSION C
WHERE (A.OBJECT_ID = B.OBJECT_ID)
AND (B.PROCESS = C.PROCESS) and a.object_name='&tb'
ORDER BY 1, 2;

set line 1000
select a.inst_id, 
          c.username,
          a.sid,     
           c.serial#,     
          c.program, 
           ' is blocking ',
           b.inst_id, 
           d.username,
           b.sid,     
          d.serial#,     
          d.program  
     from (select inst_id, sid, id1, id2 from gv$lock where block >0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and b.sid IN (SELECT 
C.SID
FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, SYS.GV_$SESSION C
WHERE (A.OBJECT_ID = B.OBJECT_ID)
AND (B.PROCESS = C.PROCESS) and a.object_name=upper('&tb')
)
;
      


1：
select blocking_instance || '.' || blocking_session blocker,
       inst_id || '.' || sid || '.' || serial# waiter
  from gv$session g
 where blocking_instance is not null
   and blocking_session is not null;
2：
select a.SID,a.SERIAL# from gv$session a where a.INST_ID=1 and a.SID=136;

select a.sid blocker_sid,a.serial#,a.username as blocker_username,b.type,
decode(b.lmode,0,'None',1,'Null',2,'Row share',3,'Row Exclusive',4,'Share',5,'Share Row Exclusive',6,'Exclusive') lock_mode,
b.ctime as time_held,c.sid as waiter_sid,
decode(c.request,0,'None',1,'Null',2,'Row share',3,'Row Exclusive',4,'Share',5,'Share Row Exclusive',6,'Exclusive') request_mode,
c.ctime time_waited 
from   v$lock b, v$enqueue_lock c, v$session a 
where  a.sid = b.sid and    b.id1= c.id1(+) and b.id2 = c.id2(+) and c.type(+) = 'TX' and  b.type = 'TX' and  b.block   = 1 order by time_held, time_waited;


-- 最优的解锁脚本
#version1
set linesize 500
col username for a9
col program for a19
select a.inst_id, 
          c.username,
          a.sid,     
           c.serial#,     
          c.program, 
           ' is blocking ',
           b.inst_id, 
           d.username,
           b.sid,     
          d.serial#,     
          d.program  
     from (select inst_id, sid, id1, id2 from gv$lock where block>0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and d.username != 'HP_DBSPI'
      ;
      
#version2    
set linesize 500
col username for a9
col program for a19
select a.inst_id, 
          c.username,
          a.sid,     
           c.serial#,     
          c.program, 
           ' is blocking ',
           b.inst_id, 
           d.username,
           b.sid,     
          d.serial#,     
          d.program  
     from (select inst_id, sid, id1, id2 from gv$lock where lmode>0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and d.username != 'HP_DBSPI'
      ;
      
#version3
set linesize 500
col username for a9
col program for a19
select a.inst_id, 
          a.lmode,
          c.username,
          a.sid,     
           c.serial#,     
          c.program, 
           ' is blocking ',
           b.inst_id, 
           d.username,
           b.sid,   
           b.request,  
          d.serial#,     
          d.program  
     from (select inst_id, sid, id1, id2 from gv$lock where block=1) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and d.username != 'HP_DBSPI'
      ;     

#version4
set linesize 500
col username for a9
col program for a19
select a.inst_id, 
          c.username,
          a.sid,     
           c.serial#,     
          c.program, 
           ' is blocking ',
           b.inst_id, 
           d.username,
           b.sid,     
          d.serial#,     
          d.program  
     from (select inst_id, sid, id1, id2 from gv$lock where block > 0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id;
      
SELECT DISTINCT  
          s1.username  
       || '@'  
       || s1.machine  
       || ' ( INST='  
       || s1.inst_id  
       || ' SID='  
       || s1.sid  
       || ' Serail#='  
       || s1.serial#  
       || ' ) IS BLOCKING '  
       || s2.username  
       || '@'  
       || s2.machine  
       || ' ( INST='  
       || s2.inst_id  
       || ' SID='  
       || s2.sid  
       || ' Serial#='  
       || s2.serial#  
       || ' ) '  
          AS blocking_status  
  FROM gv$lock l1,  
       gv$session s1,  
       gv$lock l2,  
       gv$session s2 ,
       dba_objects ao,
       v$locked_object lo
 WHERE     s1.sid = l1.sid  
       AND s2.sid = l2.sid  
       AND s1.inst_id = l1.inst_id  
       AND s2.inst_id = l2.inst_id  
       AND l1.block > 0  
       AND l2.request > 0  
       AND l1.id1 = l2.id1  
       AND l1.id2 = l2.id2
       and ao.object_id = lo.object_id  and ao.object_name=upper('test')
       ; 
       
WAITER SID    
set line 1000
select 'alter system kill session ''' || b.sid || '' || ',' || d.serial#||
       ''';' sql_text,b.inst_id
     from (select inst_id, sid, id1, id2 from gv$lock where block >0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and b.sid IN (SELECT 
C.SID
FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, SYS.GV_$SESSION C
WHERE (A.OBJECT_ID = B.OBJECT_ID)
AND (B.PROCESS = C.PROCESS))
;

BLOCK SID
set line 1000
SELECT 'alter system kill session ''' || t1.sid || '' || ',' || t1.serial#||
       ''';' sql_text,t1.inst_id from gv$session t1,(
select a.sid
     from (select inst_id, sid, id1, id2 from gv$lock where block >0) a,
          (select inst_id, sid, id1, id2 from gv$lock where request > 0) b,
          (select inst_id,sid, serial#, username,osuser, terminal, program
             from gv$session) c,
          (select inst_id,sid,
                  serial#,
                  username,            
                  program from gv$session) d
   where a.id1 = b.id1
      and a.id2 = b.id2
      and a.sid = c.sid
      and b.sid = d.sid
      and a.inst_id = c.inst_id
      and b.inst_id = d.inst_id
      and b.sid IN (SELECT 
C.SID
FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, SYS.GV_$SESSION C
WHERE (A.OBJECT_ID = B.OBJECT_ID)
AND (B.PROCESS = C.PROCESS)  and a.object_name='&NAME')) t2
where t1.sid=t2.sid
;

waiter sid
SELECT 
C.SID
FROM ALL_OBJECTS A, V$LOCKED_OBJECT B, SYS.GV_$SESSION C
WHERE (A.OBJECT_ID = B.OBJECT_ID)
AND (B.PROCESS = C.PROCESS) and a.object_name='&tb'
ORDER BY 1, 2;


查询表     
select sid,type,id1,id2,lmode,request,block from v$lock where sid in (1,28);

查询锁等待,blocker和waiter分开查询
#version1
blocker new:
SELECT t1.SID,  
       t1.SERIAL#,  
          t1.USERNAME,  
         t2.TYPE,  
         t2.ID1,  
         t2.ID2,  
         DECODE (t2.lmode,
                  0, 'None',
                  1, 'NULL',
                  2, 'ROW-S (SS)',
                  3, 'ROW-X (SX)',
                  4, 'SHARE',
                  5, 'S/ROW-X (SSX)',
                  6, 'EXCLUSIVE',
                  TO_CHAR (t2.lmode)
                 ) mode_held,
          DECODE (t2.request,
                  0, 'None',
                  1, 'NULL',
                  2, 'ROW-S (SS)',
                  3, 'ROW-X (SX)',
                  4, 'SHARE',
                  5, 'S/ROW-X (SSX)',
                  6, 'EXCLUSIVE',
                  TO_CHAR (t2.request)
                 ) mode_requested,  
         t2.CTIME,  
         t2.BLOCK  
    FROM v$session t1, v$lock t2  
   WHERE t1.SID = t2.SID  
     AND t1.USERNAME IS NOT NULL  
     AND t2.BLOCK > 0 
     and t2.lmode in (3,5,6)
   ORDER BY t2.CTIME DESC;  
waiter new:
SELECT t1.SID,  
        t1.SERIAL#,  
        t1.USERNAME,  
        t2.CTIME,  
        t2.TYPE,  
        t2.REQUEST,  
        t3.PIECE,  
        t3.SQL_TEXT  
   FROM v$session t1, v$lock t2,v$sqltext t3  
  WHERE t1.SID = t2.SID  
    AND t1.USERNAME IS NOT NULL  
    AND t1.LOCKWAIT=t2.KADDR    
    AND t3.ADDRESS = t1.SQL_ADDRESS  
    AND t3.HASH_VALUe= t1.SQL_HASH_VALUE 
    and t2.request in (3,5,6) 
  ORDER BY t2.CTIME DESC,t3.PIECE;  

#version2
blocker:
SELECT t1.SID,  
       t1.SERIAL#,  
          t1.USERNAME,  
         t2.TYPE,  
         t2.ID1,  
         t2.ID2,  
         t2.LMODE,  
         t2.REQUEST,  
         t2.CTIME,  
         t2.BLOCK  
    FROM v$session t1, v$lock t2  
   WHERE t1.SID = t2.SID  
     AND t1.USERNAME IS NOT NULL  
     AND t2.BLOCK > 0 
   ORDER BY t2.CTIME DESC;  
waiter:   
SELECT t1.SID,  
        t1.SERIAL#,  
        t1.USERNAME,  
        t2.CTIME,  
        t2.TYPE,  
        t2.REQUEST,  
        t3.PIECE,  
        t3.SQL_TEXT  
   FROM v$session t1, v$lock t2,v$sqltext t3  
  WHERE t1.SID = t2.SID  
    AND t1.USERNAME IS NOT NULL  
    AND t1.LOCKWAIT=t2.KADDR    
    AND t3.ADDRESS = t1.SQL_ADDRESS  
    AND t3.HASH_VALUe= t1.SQL_HASH_VALUE  
  ORDER BY t2.CTIME DESC,t3.PIECE;  

最原始的的脚本
#version1
set line 1000
col OBJECT format a55
col username format a22
SELECT S.SID, S.USERNAME, S.SERIAL#, O.OWNER||'.'||O.OBJECT_NAME "OBJECT", O.OBJECT_TYPE,l.lmode,l.type,l.request FROM V$LOCK L, SYS.DBA_OBJECTS O, V$SESSION S 
WHERE L.SID = S.SID AND L.ID1 = O.OBJECT_ID AND S.USERNAME IS NOT NULL and s.username != 'SYS' and s.username is not null
and O.OWNER||'.'||O.OBJECT_NAME not like 'SYS%'
ORDER BY 1;

通用脚本
#version1
col user_name format a10
col owner format a10
col object_name format a10
col object_type format a10
  SELECT   LPAD (' ', DECODE (l.xidusn, 0, 3, 0)) || l.oracle_username
              user_name,
           o.owner,
           o.object_name,
           o.object_type,
           s.sid,
           s.serial#,
           a.lmode,
           a.request,
           a.type
    FROM   v$locked_object l, dba_objects o, v$session s ,v$lock a
   WHERE   l.object_id = o.object_id AND l.session_id = s.sid and a.sid=s.sid and a.type in ('TM','TX')
ORDER BY   o.object_id, xidusn DESC;
###############
select sql_id from v$session where sid=&sid and serial#=serial#;
select sql_text from v$sql where sql_id='&sql_id';

简单查询脚本
#version1
select  /*+no_merge(a) no_merge(b) */
(select username from v$session where sid=a.sid) blocker,
a.sid, 'is blocking',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a,v$lock b
where a.block=1 and b.request>0
and a.id1=b.id1
and a.id2=b.id2;


谁锁定了谁
#version1
SELECT DECODE(request, 0, 'Holder: ', 'Waiter: ') || sid as sid,
       id1,
       id2,
       lmode,
       request,
       type,
       ctime
  FROM V$LOCK
 WHERE (id1, id2) IN (SELECT id1, id2 FROM V$LOCK WHERE request > 0)
 ORDER BY id1, ctime desc;
查询表
select sid,id1,id2,b.object_id,b.owner,b.object_name from v$Lock a,dba_objects b where a.sid=&sid and a.type='TM' and a.id1=b.object_id;

RAC
set line 1000
col sid format a30
SELECT inst_id,DECODE(request,0,'Holder: ','Waiter: ')|| sid as sid, id1, id2, lmode, 
request, type FROM GV$LOCK WHERE (inst_id, id1, id2, type) IN 
(SELECT inst_id,id1, id2, type FROM GV$LOCK WHERE request>0) ORDER BY id1, request;

set line 1000
col sid format a30
SELECT inst_id,DECODE(request,0,'Holder: ','Waiter: ')|| sid as sid, id1, id2, lmode, 
request, type FROM GV$LOCK WHERE (inst_id, id1, id2, type) IN 
(SELECT inst_id,id1, id2, type FROM GV$LOCK WHERE request>0) ORDER BY id1, request;

      
查看SPID HOST KILL -9 SPID杀死进程
#version
set line 1000
col  O.OWNER||'.'||O.OBJECT_NAME  format a30
SELECT S.SID,
       S.USERNAME,
       S.SERIAL#,
       A.spid,
       O.OWNER || '.' || O.OBJECT_NAME,
       O.OBJECT_TYPE,
       S.OSUSER,
       l.request,
       l.lmode,
       l.type
  FROM v$process A, V$LOCK L, SYS.DBA_OBJECTS O, V$SESSION S
 WHERE L.SID = S.SID
   AND L.ID1 = O.OBJECT_ID
   AND A.addr = S.paddr
   AND S.USERNAME IS NOT NULL
   and O.OWNER || '.' || O.OBJECT_NAME not like 'SYS%'
 ORDER BY 1;

select spid from v$process a,v$session b where b.sid=410 and b.SERIAL#=817 and a.addr=b.paddr;
select a.spid, b.sid, b.serial# from v$process a,v$session b where a.addr=b.paddr ORDER BY 2;

锁等待详细信息查询
使用以下脚本查找数据库中的行级锁信息
SET LINE 1000
col username for a10
col program for a25
col sid for 9999
col SERIAL# for 9999
col BLOCKING_INSTANCE for 99
select sid,serial#,username,program,status,sql_id, blocking_instance,blocking_session from v$session where event='enq: TX - row lock contention';
查找阻塞者或者被阻塞者进程信息
col event for a30
select sid,serial#,username,program,status,sql_id,event from v$session where sid='&sid';
如果阻塞者进程为ACTIVE状态，查找阻塞者进程正在执行的SQL语句
select sql_text from v$sqltext where sql_id='&sql_id';
如果阻塞者进程为ACTIVE状态，查找阻塞者进程SQL语句执行计划
select * from table(dbms_xplan.display_cursor('&sql_id'));

查询锁定，最重要的是开始时间
#version1
SELECT   l.session_id sid,
           s.serial#,
           l.locked_mode,
           l.oracle_username,
           l.os_user_name,
           s.machine,
           s.terminal,
           o.object_name,
           s.logon_time
    FROM   v$locked_object l, all_objects o, v$session s
   WHERE   l.object_id = o.object_id AND l.session_id = s.sid
ORDER BY   sid, s.serial#;

简单RAC LOCK QUERY
#version1
select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid ) blockee,
b.sid
from v$lock a, v$lock b
where a.block >0
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
/

#version2
select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid ) blockee,
b.sid
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
/

使用下面语句查找阻塞进程信息(LOCK)
如果想知道锁用了哪个回滚段，还可以关联到V$rollname，其中xidusn就是回滚段的USN
#vesion1
col user_name format a10
col owner format a10
col object_name format a10
col object_type format a10
  SELECT   LPAD (' ', DECODE (l.xidusn, 0, 3, 0)) || l.oracle_username
              user_name,
           o.owner,
           o.object_name,
           o.object_type,
           s.sid,
           s.serial#,
           l.xidusn
    FROM   v$locked_object l, dba_objects o, v$session s
   WHERE   l.object_id = o.object_id AND l.session_id = s.sid
ORDER BY   o.object_id, xidusn DESC;


RAC下的脚本
#version1
1：
select blocking_instance || '.' || blocking_session blocker,
       inst_id || '.' || sid || '.' || serial# waiter
  from gv$session g
 where blocking_instance is not null
   and blocking_session is not null;
2：
select a.SID,a.SERIAL# from gv$session a where a.INST_ID=1 and a.SID=136;


LOCK INFORMATION
##basic
lmode
0, 'None',
1, 'NULL',
2, 'ROW-S (SS)',
3, 'ROW-X (SX)',
4, 'SHARE',
5, 'S/ROW-X (SSX)',
6, 'EXCLUSIVE',
                  
request
0, 'None',
1, 'NULL',
2, 'ROW-S (SS)',
3, 'ROW-X (SX)',
4, 'SHARE',
5, 'S/ROW-X (SSX)',
6, 'EXCLUSIVE',

TX: 
TYPE
'BL','Buffer hash table', 
  'CF','Control File Transaction', 
  'CI','Cross Instance Call', 
  'CS','Control File Schema', 
  'CU','Bind Enqueue', 
  'DF','Data File', 
  'DL','Direct-loader index-creation', 
  'DM','Mount/startup db primary/secondary instance', 
  'DR','Distributed Recovery Process', 
  'DX','Distributed Transaction Entry', 
  'FI','SGA Open-File Information', 
  'FS','File Set', 
  'IN','Instance Number', 
  'IR','Instance Recovery Serialization', 
  'IS','Instance State', 
  'IV','Library Cache InValidation', 
  'JQ','Job Queue', 
  'KK','Redo Log "Kick"', 
  'LS','Log Start/Log Switch', 
  'MB','Master Buffer hash table', 
  'MM','Mount Definition', 
  'MR','Media Recovery', 
  'PF','Password File', 
  'PI','Parallel Slaves', 
  'PR','Process Startup', 
  'PS','Parallel Slaves Synchronization', 
  'RE','USE_ROW_ENQUEUE Enforcement', 
  'RT','Redo Thread', 
  'RW','Row Wait', 
  'SC','System Commit Number', 
  'SH','System Commit Number HWM', 
  'SM','SMON', 
  'SQ','Sequence Number', 
  'SR','Synchronized Replication', 
  'SS','Sort Segment', 
  'ST','Space Transaction', 
  'SV','Sequence Number Value', 
  'TA','Transaction Recovery', 
  'TD','DDL enqueue', 
  'TE','Extend-segment enqueue', 
  'TM','DML enqueue', 
  'TS','Temporary Segment', 
  'TT','Temporary Table', 
  'TX','Transaction', 
  'UL','User-defined Lock', 
  'UN','User Name', 
  'US','Undo Segment Serialization', 
  'WL','Being-written redo log instance', 
  'WS','Write-atomic-log-switch global enqueue', 
  'XA','Instance Attribute', 
  'XI','Instance Registration',
LMODE
  0,'None(0)',
  1,'Null(1)',
  2,'Row Share(2)',
  3,'Row Exclu(3)',
  4,'Share(4)',
  5,'Share Row Ex(5)',
  6,'Exclusive(6)')
REQUEST
  0,'None(0)',
  1,'Null(1)',
  2,'Row Share(2)',
  3,'Row Exclu(3)',
  4,'Share(4)',
  5,'Share Row Ex(5)',
  6,'Exclusive(6)')
 