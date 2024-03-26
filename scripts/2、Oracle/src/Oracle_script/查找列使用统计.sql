set lines 150
set pages 500
col table_name for a20
col column_name for a20
select a.object_name table_name, c.column_name,equality_preds, equijoin_preds, range_preds, like_preds
from dba_objects a, col_usage$ b, dba_tab_columns c
where a.object_id=b.OBJ#
and c.COLUMN_ID=b.INTCOL#
and a.object_name=c.table_name
and b.obj#=a.object_id
and a.object_name='&table_name'
and a.object_type='TABLE'
and a.owner='&owner'
order by 3 desc,4 desc, 5 desc;