SELECT b.tablespace,
       ROUND(((b.blocks * p.value) / 1024 / 1024), 2) || 'M' AS temp_size,
       a.inst_id as Instance,
       a.sid || ',' || a.serial# AS sid_serial,
       NVL(a.username, '(oracle)') AS username,
       a.program,
       a.status,
       a.sql_id
  FROM gv$session a, gv$sort_usage b, gv$parameter p
 WHERE p.name = 'db_block_size'
   AND a.saddr = b.session_addr
   AND a.inst_id = b.inst_id
   AND a.inst_id = p.inst_id
 ORDER BY temp_size desc 
