-- 查看数据库用户profile配置信息
SELECT profile,
       resource_name,
       resource_type,
       LIMIT
  FROM dba_profiles
 WHERE profile = 'DEFAULT';