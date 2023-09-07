with x as
--loopÌ×loopµÄÓï¾ä
 (select /*+materialize*/
   owner, name, type, line, text, rownum rn
    from dba_source
   where (upper(text) like '%ENDLOOP%' or upper(text) like '%FOR%LOOP%'))
select a.owner, a.name, a.type
  from x a, x b
 where ((upper(a.text) like '%END%LOOP%' and
       upper(b.text) like '%END%LOOP%' and a.rn + 1 = b.rn) or
       (upper(a.text) like '%FOR%LOOP%' and
       upper(b.text) like '%FOR%LOOP%' and a.rn + 1 = b.rn))
   and a.owner = b.owner
   and a.name = b.name
   and a.type = b.type
   and a.owner = 'HIPCQ'
