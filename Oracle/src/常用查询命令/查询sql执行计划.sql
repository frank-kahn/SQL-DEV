-- 查询sql执行计划  
SELECT *
  FROM TABLE(dbms_xplan.display_cursor('g4y6nw3tts7cc',
                                       NULL,
                                       'ADVANCED ALLSTATS LAST PEEKED_BINDS'));