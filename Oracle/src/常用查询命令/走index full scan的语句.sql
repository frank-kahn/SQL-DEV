--×ßindex full scanµÄÓï¾ä
select c.SQL_TEXT, c.SQL_ID, b.OBJECT_NAME, d.mb
  from v$sql_plan b,
       v$sql c,
       (select owner, segment_name, sum(bytes / 1024 / 1024) mb
          from dba_segments
         group by owner, segment_name) d
 where b.SQL_ID = c.SQL_ID
   and b.CHILD_NUMBER = c.CHILD_NUMBER
   and b.OBJECT_OWNER = 'HIPCQ'
   and b.OPERATION = 'INDEX'
   and b.OPTIONS = 'FULL SCAN'
   and b.OBJECT_OWNER = d.owner
   and b.OBJECT_NAME = d.segment_name
 order by 4 desc
