MERGE INTO target_table t
USING source_table s
ON (t.id = s.id)
WHEN MATCHED THEN
  UPDATE SET t.name = s.name, t.age = s.age
WHEN NOT MATCHED THEN
  INSERT (id, name, age) VALUES (s.id, s.name, s.age);
