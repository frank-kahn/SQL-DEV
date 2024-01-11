-- 查看阻塞的pid
select pg_blocking_pids(pid),pid,query from pg_stat_activity;
-- 锁
https://blog.csdn.net/u012551524/article/details/124195235

-- PostgreSQL中的锁 - 张树杰
https://www.modb.pro/video/5128