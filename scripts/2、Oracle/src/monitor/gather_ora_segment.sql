INSERT INTO segment_stats
   (name
   ,owner
   ,segment_name
   ,partition_name
   ,segment_type
   ,tablespace_name
   ,bytes
   ,creation_date)
   SELECT d.NAME
         ,s.owner
         ,s.segment_name
         ,s.partition_name
         ,s.segment_type
         ,s.tablespace_name
         ,s.bytes
         ,sysdate
     FROM dba_segments s
         ,v$database   d
    WHERE owner NOT IN ('SYS', 'SYSTEM')
      AND bytes >= 1 * 1024 * 1024;

INSERT INTO DB_TOTAL (total_gb,creation_date) select round(sum(bytes)/1024/1024/1024) total_gb,sysdate  as creation_date from dba_segments;

COMMIT;

EXIT;