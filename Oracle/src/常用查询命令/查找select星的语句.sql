--≤È’“select–«µƒ”Ôæ‰
select a.SQL_ID, a.SQL_TEXT, c.owner, d.table_name, d.column_cnt, c.size_mb
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
   and regexp_count(b.PROJECTION, ']') = d.column_cnt
   and c.owner = 'HIPCQ'
 order by 6 desc
