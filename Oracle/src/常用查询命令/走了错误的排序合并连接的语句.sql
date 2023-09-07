--走了错误的排序合并连接的语句
select 
c.SQL_ID,
c.SQL_TEXT,
d.owner,
d.segment_name,
d.mb

from v$sql_plan a,
            v$sql_plan b,
            v$sql c,
            (select owner, segment_name, sum(bytes / 1024 / 1024) mb
               from dba_segments
              group by owner, segment_name)d
              where a.SQL_ID=b.SQL_ID
              and a.CHILD_NUMBER=b.CHILD_NUMBER
              and b.OPERATION='SORT'
              and b.OPTIONS='JOIN'
              and b.ACCESS_PREDICATES like '%"="%'
              and a.PARENT_ID=b.id
              and a.OBJECT_OWNER='HIPCQ'
              and b.sql_id=c.sql_id
              and b.CHILD_NUMBER=c.CHILD_NUMBER
              and a.OBJECT_OWNER=d.owner
              and a.OBJECT_NAME=d.segment_name
              order by 4 desc
