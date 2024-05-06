create schema IF NOT EXISTS  dba;
create view dba.get_lock1 as 
SELECT                                      
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    now() - blocked_activity.query_start AS blocked_duration,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    now() - blocking_activity.query_start AS blocking_duration,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS blocking_statement
FROM                                                       
    pg_catalog.pg_locks AS blocked_locks
    JOIN pg_catalog.pg_stat_activity AS blocked_activity ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks AS blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
    JOIN pg_catalog.pg_stat_activity AS blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE
    NOT blocked_locks.granted;
    
create view dba.get_lock2 as 
WITH RECURSIVE
  lock_composite(requested, current) AS (VALUES
    ('AccessShareLock'::text, 'AccessExclusiveLock'::text),
    ('RowShareLock'::text, 'ExclusiveLock'::text),
    ('RowShareLock'::text, 'AccessExclusiveLock'::text),
    ('RowExclusiveLock'::text, 'ShareLock'::text),
    ('RowExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
    ('RowExclusiveLock'::text, 'ExclusiveLock'::text),
    ('RowExclusiveLock'::text, 'AccessExclusiveLock'::text),
    ('ShareUpdateExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
    ('ShareUpdateExclusiveLock'::text, 'ShareLock'::text),
    ('ShareUpdateExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
    ('ShareUpdateExclusiveLock'::text, 'ExclusiveLock'::text),
    ('ShareUpdateExclusiveLock'::text, 'AccessExclusiveLock'::text),
    ('ShareLock'::text, 'RowExclusiveLock'::text),
    ('ShareLock'::text, 'ShareUpdateExclusiveLock'::text),
    ('ShareLock'::text, 'ShareRowExclusiveLock'::text),
    ('ShareLock'::text, 'ExclusiveLock'::text),
    ('ShareLock'::text, 'AccessExclusiveLock'::text),
    ('ShareRowExclusiveLock'::text, 'RowExclusiveLock'::text),
    ('ShareRowExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
    ('ShareRowExclusiveLock'::text, 'ShareLock'::text),
    ('ShareRowExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
    ('ShareRowExclusiveLock'::text, 'ExclusiveLock'::text),
    ('ShareRowExclusiveLock'::text, 'AccessExclusiveLock'::text),
    ('ExclusiveLock'::text, 'RowShareLock'::text),
    ('ExclusiveLock'::text, 'RowExclusiveLock'::text),
    ('ExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
    ('ExclusiveLock'::text, 'ShareLock'::text),
    ('ExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
    ('ExclusiveLock'::text, 'ExclusiveLock'::text),
    ('ExclusiveLock'::text, 'AccessExclusiveLock'::text),
    ('AccessExclusiveLock'::text, 'AccessShareLock'::text),
    ('AccessExclusiveLock'::text, 'RowShareLock'::text),
    ('AccessExclusiveLock'::text, 'RowExclusiveLock'::text),
    ('AccessExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
    ('AccessExclusiveLock'::text, 'ShareLock'::text),
    ('AccessExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
    ('AccessExclusiveLock'::text, 'ExclusiveLock'::text),
    ('AccessExclusiveLock'::text, 'AccessExclusiveLock'::text)
  )
, lock AS (
  SELECT pid,
     virtualtransaction,
     granted,
     mode,
    (locktype,
     CASE locktype
       WHEN 'relation'      THEN concat_ws(';', 'db:'||datname, 'rel:'||relation::regclass::text)
       WHEN 'extend'        THEN concat_ws(';', 'db:'||datname, 'rel:'||relation::regclass::text)
       WHEN 'page'          THEN concat_ws(';', 'db:'||datname, 'rel:'||relation::regclass::text, 'page#'||page::text)
       WHEN 'tuple'         THEN concat_ws(';', 'db:'||datname, 'rel:'||relation::regclass::text, 'page#'||page::text, 'tuple#'||tuple::text)
       WHEN 'transactionid' THEN transactionid::text
       WHEN 'virtualxid'    THEN virtualxid::text
       WHEN 'object'        THEN concat_ws(';', 'class:'||classid::regclass::text, 'objid:'||objid, 'col#'||objsubid)
       ELSE concat('db:'||datname)
     END::text) AS target
  FROM pg_catalog.pg_locks
  LEFT JOIN pg_catalog.pg_database ON (pg_database.oid = pg_locks.database)
  )
, waiting_lock AS (
  SELECT
    blocker.pid                         AS blocker_pid,
    blocked.pid                         AS pid,
    concat(blocked.mode,blocked.target) AS lock_target
  FROM lock blocker
  JOIN lock blocked
    ON ( NOT blocked.granted
     AND blocker.granted
     AND blocked.pid != blocker.pid
     AND blocked.target IS NOT DISTINCT FROM blocker.target)
  JOIN lock_composite c ON (c.requested = blocked.mode AND c.current = blocker.mode)
  )
, acquired_lock AS (
  WITH waiting AS (
    SELECT lock_target, count(lock_target) AS wait_count FROM waiting_lock GROUP BY lock_target
  )
  SELECT
    pid,
    array_agg(concat(mode,target,' + '||wait_count) ORDER BY wait_count DESC NULLS LAST) AS locks_acquired
  FROM lock
    LEFT JOIN waiting ON waiting.lock_target = concat(mode,target)
  WHERE granted
  GROUP BY pid
  )
, blocking_lock AS (
  SELECT
    ARRAY[date_part('epoch', query_start)::int, pid] AS seq,
     0::int AS depth,
    -1::int AS blocker_pid,
    pid,
    concat('Connect: ',usename,' ',datname,' ',coalesce(host(client_addr)||':'||client_port, 'local')
      , E'\nSQL: ',replace(substr(coalesce(query,'N/A'), 1, 60), E'\n', ' ')
      , E'\nAcquired:\n  '
      , array_to_string(locks_acquired[1:5] ||
                        CASE WHEN array_upper(locks_acquired,1) > 5
                             THEN '... '||(array_upper(locks_acquired,1) - 5)::text||' more ...'
                        END,
                        E'\n  ')
    ) AS lock_info,
    concat(to_char(query_start, CASE WHEN age(query_start) > '24h' THEN 'Day DD Mon' ELSE 'HH24:MI:SS' END),E' started\n'
          ,CASE WHEN wait_event IS NOT NULL THEN 'waiting' ELSE state END,E'\n'
          ,date_trunc('second',age(now(),query_start)),' ago'
    ) AS lock_state
  FROM acquired_lock blocker
  LEFT JOIN pg_stat_activity act USING (pid)
  WHERE EXISTS
         (SELECT 'x' FROM waiting_lock blocked WHERE blocked.blocker_pid = blocker.pid)
    AND NOT EXISTS
         (SELECT 'x' FROM waiting_lock blocked WHERE blocked.pid = blocker.pid)
UNION ALL
  SELECT
    blocker.seq || blocked.pid,
    blocker.depth + 1,
    blocker.pid,
    blocked.pid,
    concat('Connect: ',usename,' ',datname,' ',coalesce(host(client_addr)||':'||client_port, 'local')
      , E'\nSQL: ',replace(substr(coalesce(query,'N/A'), 1, 60), E'\n', ' ')
      , E'\nWaiting: ',blocked.lock_target
      , CASE WHEN locks_acquired IS NOT NULL
             THEN E'\nAcquired:\n  ' ||
                  array_to_string(locks_acquired[1:5] ||
                                  CASE WHEN array_upper(locks_acquired,1) > 5
                                       THEN '... '||(array_upper(locks_acquired,1) - 5)::text||' more ...'
                                  END,
                                  E'\n  ')
        END
    ) AS lock_info,
    concat(to_char(query_start, CASE WHEN age(query_start) > '24h' THEN 'Day DD Mon' ELSE 'HH24:MI:SS' END),E' started\n'
          ,CASE WHEN wait_event IS NOT NULL THEN 'waiting' ELSE state END,E'\n'
          ,date_trunc('second',age(now(),query_start)),' ago'
    ) AS lock_state
  FROM blocking_lock blocker
  JOIN waiting_lock blocked
    ON (blocked.blocker_pid = blocker.pid)
  LEFT JOIN pg_stat_activity act ON (act.pid = blocked.pid)
  LEFT JOIN acquired_lock acq ON (acq.pid = blocked.pid)
  WHERE blocker.depth < 5
  )
SELECT concat(lpad('=> ', 4*depth, ' '),pid::text) AS "PID"
, lock_info AS "Lock Info"
, lock_state AS "State"
FROM blocking_lock
ORDER BY seq;

create view dba.get_lock3 as 
WITH RECURSIVE t_wait AS (
    SELECT
        a.locktype,
        a.database,
        a.relation,
        a.page,
        a.tuple,
        a.classid,
        a.objid,
        a.objsubid,
        a.pid,
        a.virtualtransaction,
        a.virtualxid,
        a.transactionid
    FROM
        pg_locks a
    WHERE
        NOT a.granted
),
t_run AS (
    SELECT
        a.mode,
        a.locktype,
        a.database,
        a.relation,
        a.page,
        a.tuple,
        a.classid,
        a.objid,
        a.objsubid,
        a.pid,
        a.virtualtransaction,
        a.virtualxid,
        a.transactionid,
        b.query,
        b.xact_start,
        b.query_start,
        b.usename,
        b.datname
    FROM
        pg_locks a,
        pg_stat_activity b
    WHERE
        a.pid = b.pid
        AND a.granted
),
w AS (
    SELECT
        r.pid r_pid,
        w.pid w_pid
    FROM
        t_wait w,
        t_run r
    WHERE
        r.locktype IS NOT DISTINCT FROM w.locktype
        AND r.database IS NOT DISTINCT FROM w.database
        AND r.relation IS NOT DISTINCT FROM w.relation
        AND r.page IS NOT DISTINCT FROM w.page
        AND r.tuple IS NOT DISTINCT FROM w.tuple
        AND r.classid IS NOT DISTINCT FROM w.classid
        AND r.objid IS NOT DISTINCT FROM w.objid
        AND r.objsubid IS NOT DISTINCT FROM w.objsubid
        AND r.transactionid IS NOT DISTINCT FROM w.transactionid
        AND r.virtualxid IS NOT DISTINCT FROM w.virtualxid
),
c (
    waiter, holder, root_holder, path, deep
) AS (
    SELECT
        w_pid,
        r_pid,
        r_pid,
        w_pid || '->' || r_pid,
        1
    FROM
        w
    UNION
    SELECT
        w_pid,
        r_pid,
        c.holder,
        w_pid || '->' || c.path,
        c.deep + 1
    FROM
        w t,
        c
    WHERE
        t.r_pid = c.waiter
)
SELECT
    t1.waiter,
    t1.holder,
    t1.root_holder,
    path,
    t1.deep
FROM
    c t1
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            c t2
        WHERE
            t2.path ~ t1.path
            AND t1.path <> t2.path)
ORDER BY
    root_holder;
    
create view dba.get_lock4 as with      
t_wait as      
(      
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,     
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,      
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name     
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted     
),     
t_run as     
(     
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,     
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,     
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name     
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted     
),     
t_overlap as     
(     
  select r.* from t_wait w join t_run r on     
  (     
    r.locktype is not distinct from w.locktype and     
    r.database is not distinct from w.database and     
    r.relation is not distinct from w.relation and     
    r.page is not distinct from w.page and     
    r.tuple is not distinct from w.tuple and     
    r.virtualxid is not distinct from w.virtualxid and     
    r.transactionid is not distinct from w.transactionid and     
    r.classid is not distinct from w.classid and     
    r.objid is not distinct from w.objid and     
    r.objsubid is not distinct from w.objsubid and     
    r.pid <> w.pid     
  )      
),      
t_unionall as      
(      
  select r.* from t_overlap r      
  union all      
  select w.* from t_wait w      
)      
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,     
string_agg(     
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||     
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||     
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||      
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||      
'SQL (Current SQL in Transaction): '||chr(10)||    
case when query is null then 'NULL' else query::text end,      
chr(10)||'--------'||chr(10)      
order by      
  (  case mode      
    when 'INVALID' then 0     
    when 'AccessShareLock' then 1     
    when 'RowShareLock' then 2     
    when 'RowExclusiveLock' then 3     
    when 'ShareUpdateExclusiveLock' then 4     
    when 'ShareLock' then 5     
    when 'ShareRowExclusiveLock' then 6     
    when 'ExclusiveLock' then 7     
    when 'AccessExclusiveLock' then 8     
    else 0     
  end  ) desc,     
  (case when granted then 0 else 1 end)    
) as lock_conflict    
from t_unionall     
group by     
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;  
  
select * from dba.get_lock1;
select * from dba.get_lock2;
select * from dba.get_lock3;
\x
select * from dba.get_lock4;

