-- 阻塞锁信息查询        
       SELECT rpad('+',
            LEVEL,
            '-') || sid || ' ' || sess.module session_detail,
       sid,
       serial#,
       'alter system kill session ''' || sid || ',' || serial# || ',@' || sess.inst_id || ''' immediate;' AS kill_sql,
       blocker_sid,
       sess.inst_id,
       wait_event_text,
       object_name,
       rpad(' ',
            LEVEL) || sql_text sql_text
  FROM v$wait_chains c
  LEFT OUTER JOIN dba_objects o
    ON (row_wait_obj# = object_id)
  JOIN gv$session sess
 USING (sid)
  LEFT OUTER JOIN v$sql SQL
    ON (sql.sql_id = sess.sql_id AND sql.child_number = sess.sql_child_number)
CONNECT BY PRIOR sid = blocker_sid
       AND PRIOR sess_serial# = blocker_sess_serial#
       AND PRIOR instance = blocker_instance
 START WITH blocker_is_valid = 'FALSE';