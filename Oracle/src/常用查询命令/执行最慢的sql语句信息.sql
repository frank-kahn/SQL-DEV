-- 执行最慢的sql语句信息
SELECT *
  FROM (SELECT sa.sql_id,
               sa.sql_text,
               sa.sql_fulltext,
               sa.executions,
               round(sa.elapsed_time / 1000000,
                     2) total_time,
               round(sa.elapsed_time / 1000000 / sa.executions,
                     2) sec_time,
               u.username
          FROM v$sqlarea sa
          LEFT JOIN dba_users u
            ON sa.parsing_user_id = u.user_id
           AND u.account_status = 'OPEN'
         WHERE sa.executions > 0
           AND username NOT IN ('SYSTEM',
                                'SYS',
                                'ORACLE_OCM',
                                'DBSNMP',
                                'APEX_030200')
         ORDER BY (sa.elapsed_time / sa.executions) DESC)
 WHERE rownum <= 50;