--索引被哪些语句使用
select a.SQL_TEXT, a.SQL_ID, b.OBJECT_OWNER, b.OBJECT_NAME, b.OBJECT_TYPE
  from v$sql a, v$sql_plan b
 where a.SQL_ID = b.SQL_ID
   and a.CHILD_NUMBER = b.CHILD_NUMBER
   and object_owner = 'HIPCQ'
   and object_type like '%INDEX%'
 order by 3, 4, 5
