--×ßÁËFiterµÄÓï¾ä
select parsing_schema_name schema,sql_id,sql_text from v$sql
where parsing_schema_name='HIPCQ'
and (sql_id,child_number) in
(select sql_id,CHILD_NUMBER from v$sql_plan
where operation='FILTER'
and filter_predicates like '%IS NOT NULL%'
minus
select sql_id,CHILD_NUMBER from v$sql_plan
where object_owner='SYS'
)
 
