--可以创建组合索引的语句(回表再过滤选择性高的列)
select a.SQL_ID,
       a.SQL_TEXT,
       f.TABLE_NAME,
       c.size_mb,
       e.column_name,
       round(e.num_distinct / f.NUM_ROWS * 100, 2) selectivity
  from v$sql a,
       v$sql_plan b,
       (select owner, segment_name, sum(bytes / 1024 / 1024) size_mb
          from dba_segments
         group by owner, segment_name) c,
       dba_tab_col_statistics e,
       dba_tables f
where a.SQL_ID=b.SQL_ID
and a.CHILD_NUMBER=b.CHILD_NUMBER
and b.OBJECT_OWNER=c.owner
and b.OBJECT_NAME=c.segment_name
and e.owner=f.OWNER
and b.OBJECT_NAME=f.TABLE_NAME
and instr(b.FILTER_PREDICATES,e.column_name)>0
and (e.num_distinct/f.NUM_ROWS)>0.1
and c.owner='HIPCQ'
and b.OPERATION='TABLE ACCESS'
and b.OPTIONS='BY INDEX ROWID'
and e.owner='HIPCQ'
order by 4 desc
