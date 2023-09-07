-- 查看游标使用情况   

SELECT 'session_cached_cursors' parameter,
       lpad(VALUE,
            5) VALUE,
       decode(VALUE,
              0,
              ' n/a',
              to_char(100 * used / VALUE,
                      '990') || '%') usage
  FROM (SELECT MAX(s.value) used
          FROM v$statname n,
               v$sesstat  s
         WHERE n.name = 'session cursor cache count'
           AND s.statistic# = n.statistic#),
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'session_cached_cursors')
UNION ALL
SELECT 'open_cursors',
       lpad(VALUE,
            5),
       to_char(100 * used / VALUE,
               '990') || '%'
  FROM (SELECT MAX(SUM(s.value)) used
          FROM v$statname n,
               v$sesstat  s
         WHERE n.name IN ('opened cursors current')
           AND s.statistic# = n.statistic#
         GROUP BY s.sid),
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'open_cursors');
