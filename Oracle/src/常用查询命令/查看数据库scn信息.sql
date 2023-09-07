-- 查看数据库scn信息  
SELECT to_char(created,
               'yyyy-mm-dd hh24:mi:ss') TIME,
       dbms_flashback.get_system_change_number scn,
       round(((((((to_number(to_char(SYSDATE,
                                     'YYYY')) - 1988) * 12 * 31 * 24 * 60 * 60) +
             ((to_number(to_char(SYSDATE,
                                     'MM')) - 1) * 31 * 24 * 60 * 60) +
             (((to_number(to_char(SYSDATE,
                                      'DD')) - 1)) * 24 * 60 * 60) +
             (to_number(to_char(SYSDATE,
                                    'HH24')) * 60 * 60) + (to_number(to_char(SYSDATE,
                                                                                 'MI')) * 60) +
             (to_number(to_char(SYSDATE,
                                    'SS')))) * (16 * 1024)) - dbms_flashback.get_system_change_number) / (16 * 1024 * 60 * 60 * 24)),
             2) headroom
  FROM v$database;
