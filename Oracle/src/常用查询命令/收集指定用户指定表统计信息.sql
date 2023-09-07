-- 收集指定用户指定表统计信息       
BEGIN
  dbms_stats.gather_table_stats(ownname          => 'LUCIFER',
                                tabname          => 'LUCIFER',
                                estimate_percent => 100,
                                method_opt       => 'FOR ALL COLUMNS SIZE 1',
                                cascade          => TRUE,
                                no_invalidate    => FALSE);
END;
/