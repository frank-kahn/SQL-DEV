--抓出有标量子查询的语句
select sql_id, SQL_TEXT, MODULE
  from v$sql
 where parsing_schema_name = 'HIPCQ'
   --and module = 'SQL*PLUS'
   and sql_id in
       (select sql_id
          from (select sql_id,
                       count(*) over(partition by sql_id, child_number, depth) cnt
                  from v$sql_plan
         where depth = 1
           and (object_owner='HIPCQ' or object_owner is null)) where cnt>= 2)
