-- 创建awr快照   
BEGIN
  dbms_workload_repository.create_snapshot();
END;
/