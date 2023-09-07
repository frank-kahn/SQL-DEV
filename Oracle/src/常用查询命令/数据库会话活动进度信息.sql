-- 数据库会话活动进度信息 
SELECT inst_id,
       sid,
       username,
       sql_id,
       opname,
       start_time,
       elapsed_seconds,
       time_remaining,
       round(sofar * 100 / totalwork,
             2) exec_pct,
       CONTEXT dfo
  FROM gv$session_longops
 WHERE time_remaining > 0
 ORDER BY elapsed_seconds DESC;