--表被多次反复调用的语句
select a.PARSING_SCHEMA_NAME schema,
       a.SQL_ID,
       a.SQL_TEXT,
       b.object_name,
       b.cnt
  from v$sql a,
       (select *
          from (select sql_id,
                       child_number,
                       object_owner,
                       object_name,
                       object_type,
                       count(*) cnt
                  from v$sql_plan
                 where object_owner = 'HIPCQ'
                 group by sql_id,
                          child_number,
                          object_owner,
                          object_name,
                          object_type)
         where cnt >= 2) b
 where a.SQL_ID = b.sql_id
   and a.CHILD_NUMBER = b.child_number
