SELECT RPAD('+', LEVEL, '-') || sid || ' ' || sess.module as session_level,   --锁关系层级
       sess.inst_id as inst_id,    --会话实例
       sid,   
       SERIAL#,
       osid,
       username,
       machine,
       program,
       sess.sql_id as sql_id,
       object_name,
       wait_event_text,
       in_wait_secs,        --阻塞时间
       num_waiters,         --此会话阻塞的会话数
       'SID:' || blocker_sid || ',' || blocker_sess_serial# || ',@' ||   
       blocker_instance as blk_info,    --上级阻塞者
       'SID:' || final_blocking_session || ',@' || final_blocking_instance as f_blk_info,   --最终阻塞者
       'alter system kill session ''' || SID || ',' || SERIAL# || ',@' ||     
       sess.inst_id || ''' immediate;' as kill_sql,  ---杀锁会话
       RPAD(' ', LEVEL) || sql_text sql_text  --锁会话sql
  FROM v$wait_chains c
  LEFT OUTER JOIN dba_objects o
    ON (row_wait_obj# = object_id)
  JOIN gv$session sess
 USING (sid)
  LEFT OUTER JOIN gv$sql sql
    ON (sql.sql_id = sess.sql_id AND
       sql.child_number = sess.sql_child_number)
CONNECT BY PRIOR sid = blocker_sid
       AND PRIOR sess_serial# = blocker_sess_serial#
       AND PRIOR INSTANCE = blocker_instance
 START WITH blocker_is_valid = 'FALSE'
        and num_waiters <> 0;
