-- 根据系统进程查看该进程信息    
SELECT '实例             :' || s.inst_id || chr(10) || '用户名           :' || s.username || chr(10) || '对象名           :' || s.schemaname || chr(10) ||
       '系统用户         :' || s.osuser || chr(10) || '进程名           :' || s.program || chr(10) || '进程号           :' || p.spid || chr(10) ||
       'SERIAL#          :' || s.serial# || chr(10) || '会话Kill信息     :' || 'alter system kill session ' || s.sid || ',' || s.serial# || ',@' ||
       s.inst_id || ' immediate;' || chr(10) || '类型             :' || s.type || chr(10) || '终端             :' || s.terminal || chr(10) ||
       'SQL_ID           :' || q.sql_id
  FROM gv$session s,
       gv$process p,
       v$sql      q
 WHERE s.paddr = p.addr
   AND p.spid = '3076'
   AND s.sql_id = q.sql_id(+);
                          
-- Oracle DataGuard状态   
SELECT *
  FROM (SELECT rownum,
               NAME,
               creator,
               sequence#,
               applied,
               completion_time
          FROM v$archived_log
         ORDER BY completion_time DESC)
 WHERE rownum < 10;