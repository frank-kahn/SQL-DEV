-- 执行计划
explain(analyze true,verbose true,costs true,buffers true,timing true,format text)


-- 表膨胀信息
SELECT
  schemaname||'.'||relname as table_name,
  pg_size_pretty(pg_relation_size(schemaname||'.'||relname)) as table_size,
  n_dead_tup,
  n_live_tup,
round(n_dead_tup * 100 / (n_live_tup + n_dead_tup),2) AS dead_tup_ratio
FROM pg_stat_all_tables
WHERE relname = 'fgedu_carid';