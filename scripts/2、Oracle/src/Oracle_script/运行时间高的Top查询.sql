--Queries in last 1 hour ( Run from Toad, for proper view)

Select module,parsing_schema_name,inst_id,sql_id,CHILD_NUMBER,sql_plan_baseline,sql_profile,plan_hash_value,sql_fulltext,
to_char(last_active_time,'DD/MM/YY HH24:MI:SS' ),executions, elapsed_time/executions/1000/1000,
rows_processed,sql_plan_baseline from gv$sql where last_active_time>sysdate-1/24 
and executions <> 0 order by elapsed_time/executions desc