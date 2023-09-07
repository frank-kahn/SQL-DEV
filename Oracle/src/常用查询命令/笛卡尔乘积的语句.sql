--µÑ¿¨¶û³Ë»ýµÄÓï¾ä
select c.SQL_TEXT,
       a.SQL_ID,
       b.object_name,
       a.FILTER_PREDICATES filter,
       a.ACCESS_PREDICATES predicate,
       d.mb
  from v$sql_plan a,
       (select *
          from (select sql_id,
                       child_number,
                       object_owner,
                       object_name,
                       parent_id,
                       operation,
                       options,
                       row_number() over(partition by sql_id, child_number, parent_id order by id) rn
                  from v$sql_plan)
         where rn = 1) b,
       v$sql c,
       (select owner, segment_name, sum(bytes / 1024 / 1024) mb
          from dba_segments
         group by owner, segment_name) d
 where b.sql_id = c.SQL_ID
   and b.child_number = c.CHILD_NUMBER
   and b.object_owner = 'HIPCQ'
   and a.SQL_ID = b.sql_id
   and a.CHILD_NUMBER = b.child_number
   and a.OPERATION = 'MERGE JOIN'
   and a.ID = b.parent_id
   and a.OPTIONS = 'CAETESTIAN'
   and b.object_owner = d.owner
   and b.object_name = d.segment_name
 order by 4 desc
