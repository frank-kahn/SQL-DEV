-- 高水位收缩拼接语句    
SELECT segment_name,
       'ALTER TABLE ' || segment_name || ' ENABLE ROW MOVEMENT;' || chr(10) || 'ALTER TABLE ' || segment_name || ' SHRINK SPACE;'
  FROM (SELECT a.segment_name
          FROM sys.dba_segments a,
               sys.dba_tables   b,
               sys.ts$          c
         WHERE a.owner = b.owner
           AND segment_name = table_name
           AND segment_type = 'TABLE'
           AND b.tablespace_name = c.name
           AND greatest(round(100 *
                              (nvl(a.blocks - b.empty_blocks - 1 - decode(round((b.avg_row_len * num_rows * (1 + (pct_free / 100))) / c.blocksize,
                                                                                0),
                                                                          0,
                                                                          1,
                                                                          round((b.avg_row_len * num_rows * (1 + (pct_free / 100))) / c.blocksize,
                                                                                0)) + 2,
                                   0) / greatest(nvl(a.blocks - b.empty_blocks - 1,
                                                      1),
                                                  1)),
                              2),
                        0) > 25
           AND a.owner = 'LUCIFER'
           AND a.blocks > 128
        UNION ALL
        SELECT DISTINCT a.segment_name segment_name
          FROM sys.dba_segments       a,
               sys.dba_tab_partitions b,
               sys.ts$                c,
               sys.dba_tables         d
         WHERE a.owner = b.table_owner
           AND segment_name = b.table_name
           AND segment_type = 'TABLE PARTITION'
           AND b.tablespace_name = c.name
           AND d.owner = b.table_owner
           AND d.table_name = b.table_name
           AND a.partition_name = b.partition_name
           AND greatest(round(100 *
                              (nvl(a.blocks - b.empty_blocks - 1 - decode(round((b.avg_row_len * b.num_rows * (1 + (b.pct_free / 100))) / c.blocksize,
                                                                                0),
                                                                          0,
                                                                          1,
                                                                          round((b.avg_row_len * b.num_rows * (1 + (b.pct_free / 100))) / c.blocksize,
                                                                                0)) + 2,
                                   0) / greatest(nvl(a.blocks - b.empty_blocks - 1,
                                                      1),
                                                  1)),
                              2),
                        0) > 25
           AND a.owner = 'LUCIFER'
           AND a.blocks > 128);