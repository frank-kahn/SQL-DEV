https://www.modb.pro/video/7453
PostgreSQL DBA one day



PostgreSQL日常工作分享
https://www.modb.pro/video/3668

PostgreSQL深入学习与运维管理方法论
https://www.modb.pro/video/3206


PostgreSQL疑难案例分享
https://www.modb.pro/video/3202




--权限管理
https://blog.csdn.net/eagle89/article/details/112169903
https://www.cnblogs.com/xiaotengyi/p/10132083.html
https://blog.csdn.net/suoyue_py/article/details/121159908

--运维文档
https://blog.csdn.net/qq_33445829/article/details/126636295?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522166347961116800184174899%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=166347961116800184174899&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-1-126636295-null-null.142^v47^control_1,201^v3^control_1&utm_term=%E3%80%90postgressql%E6%95%B0%E6%8D%AE%E5%BA%93%E8%BF%90%E7%BB%B4%E6%96%87%E6%A1%A3%E3%80%91&spm=1018.2226.3001.4187


--火焰图
https://www.modb.pro/db/49039



-- 怎么样一次查出某个用户下对象的依赖关系影响

https://pgfans.cn/q/805

WITH RECURSIVE x AS
(
 SELECT member::regrole,
     roleid::regrole AS role,
     member::regrole || ' -> ' || roleid::regrole AS path
 FROM pg_auth_members AS m
 WHERE roleid > 16384
 UNION ALL
 SELECT x.member::regrole,
     m.roleid::regrole,
     x.path || ' -> ' || m.roleid::regrole
 FROM pg_auth_members AS m
  JOIN x ON m.member = x.role
 )
 SELECT member, role, path
 FROM x
 ORDER BY member::text, role::text;

关于PG里的VACUUM
https://pgfans.cn/a/2093
 
 


--离线安装postgresql数据库
https://blog.51cto.com/u_15162069/2779522


--Postgresql 如何清理WAL日志
https://www.jb51.net/article/203835.htm




postgresql ha patroni
https://blog.csdn.net/ctypyb2002/category_8091948.html









dvdrental=# select chr(36731)|| chr(33311)|| chr(24050)|| chr(36807)|| chr(19975)|| chr(37325)|| chr(23665);
    ?column?    
----------------
 轻舟已过万重山
(1 row) 



