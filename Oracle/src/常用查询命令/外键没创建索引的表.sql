--外键没创建索引的表
with cons as
 (select /*+materialize*/
   owner, table_name, constraint_name
    from dba_constraints
   where owner = 'HIPCQ'
     and constraint_type = 'R'),
idx as
 (select /*+materialize*/
   table_owner, table_name, column_name
    from dba_ind_columns
   where table_owner = 'HIPCQ')
select owner, table_name, constraint_name, column_name
  from dba_cons_columns
 where (owner, table_name, constraint_name) in (select * from cons)
   and (owner, table_name, constraint_name) not in (select * from idx)
