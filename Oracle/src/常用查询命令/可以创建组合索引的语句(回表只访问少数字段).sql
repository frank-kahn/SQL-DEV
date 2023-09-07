--可以创建组合索引的语句(回表只访问少数字段)
select a.SQL_ID,
       a.SQL_TEXT,
       d.table_name,
       regexp_count(b.PROJECTION, ']') || '/' || d.column_cnt column_cnt,
       c.size_mb,
       b.FILTER_PREDICATES filter

  from v$sql a,
       v$sql_plan b,
       (select owner, segment_name, sum(bytes / 1024 / 1024) size_mb
          from dba_segments
         group by owner, segment_name) c,
       (select owner, table_name, count(*) column_cnt
          from dba_tab_cols
         group by owner, table_name) d
 where a.SQL_ID = b.SQL_ID
   and a.CHILD_NUMBER = b.CHILD_NUMBER
   and b.OBJECT_OWNER = c.owner
   and b.OBJECT_NAME = c.segment_name
   and b.OBJECT_OWNER = d.owner
   and b.OBJECT_NAME = d.table_name
   and c.owner = 'HIPCQ'
   and b.OPERATION = 'TABLE ACCESS'
   and b.OPTIONS = 'BY INDEX ROWID'
   and regexp_count(b.PROJECTION, ']') / d.column_cnt < 0.25
 order by 5 desc
