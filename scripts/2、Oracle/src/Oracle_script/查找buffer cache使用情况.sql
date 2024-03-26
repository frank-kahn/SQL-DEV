col object_name format a30
col to_total format 999.99

SELECT owner, object_name, object_type, count, (count / value) * 100 to_total
FROM (
SELECT a.owner, a.object_name, a.object_type,
count(*) count
FROM dba_objects a,
x$bh b
WHERE a.object_id = b.obj
and a.owner not in ('SYS', 'SYSTEM')
GROUP BY a.owner, a.object_name, a.object_type
ORDER BY 4),
v$parameter
WHERE name = 'db_cache_size'
AND (count / value) * 100 > .005
ORDER BY to_total desc
/