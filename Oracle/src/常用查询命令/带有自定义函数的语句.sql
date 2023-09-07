--带有自定义函数的语句
select distinct sql_id, sql_text, module
  from v$sql,
       (select object_name
          from dba_objects
         where owner = 'HIPCQ'
           and object_type in ('FUNCTION', 'PACKAGE'))
 where (instr(upper(sql_text), object_name) > 0) and plsql_exec_time > 0 and regexp_like(upper(sql_fulltext), '^[SELECT]') and parsing_schema_name = 'HIPCQ'
