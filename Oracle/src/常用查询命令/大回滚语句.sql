--大回滚语句
SELECT a.tablespace_name,
       SUM(decode(a.status, 'ACTIVE', a.bytes)) / 1024 / 1024 "Active(M)",
       SUM(decode(a.status, 'EXPIRED', a.bytes)) / 1024 / 1024 "Expire(M)",
       SUM(decode(a.status, 'UNEXPIRED', a.bytes)) / 1024 / 1024 "Unexpire(M)",
       sum(a.bytes) / 1024 / 1024 "Total(M)"
  FROM dba_undo_extents a
GROUP BY a.tablespace_name;