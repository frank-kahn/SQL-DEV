--抓出返回行数较多的嵌套循环语句
select *
  from (select parsing_schema_name schema,
               sql_id,
               sql_text,
               rows_processed / executions rows_processed
          from v$sql
         where parsing_schema_name = 'HIPCQ'
           and executions > 0
           and rows_processed / executions > 10000
         order by 4 desc) a
 where a.sql_id in (select sql_id
                      from v$sql_plan
                     where operation like '%NESTED LOOPS%'
                       and id <= 5)
