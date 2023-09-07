-- 高水位对象信息查看 
SELECT owner,
       segment_name table_name,
       segment_type,
       greatest(round(100 * (nvl(hwm - avg_used_blocks,
                                 0) / greatest(nvl(hwm,
                                                          1),
                                                      1)),
                      2),
                0) waste_per,
       round(bytes / 1024,
             2) table_kb,
       num_rows,
       blocks,
       empty_blocks,
       hwm highwater_mark,
       avg_used_blocks,
       chain_per,
       extents,
       max_extents,
       allo_extent_per,
       decode(greatest(max_free_space - next_extent,
                       0),
              0,
              'N',
              'Y') can_extend_space,
       next_extent,
       max_free_space,
       o_tablespace_name tablespace_name
  FROM (SELECT a.owner owner,
               a.segment_name,
               a.segment_type,
               a.bytes,
               b.num_rows,
               a.blocks blocks,
               b.empty_blocks empty_blocks,
               a.blocks - b.empty_blocks - 1 hwm,
               decode(round((b.avg_row_len * num_rows * (1 + (pct_free / 100))) / c.blocksize,
                            0),
                      0,
                      1,
                      round((b.avg_row_len * num_rows * (1 + (pct_free / 100))) / c.blocksize,
                            0)) + 2 avg_used_blocks,
               round(100 * (nvl(b.chain_cnt,
                                0) / greatest(nvl(b.num_rows,
                                                         1),
                                                     1)),
                     2) chain_per,
               round(100 * (a.extents / a.max_extents),
                     2) allo_extent_per,
               a.extents extents,
               a.max_extents max_extents,
               b.next_extent next_extent,
               b.tablespace_name o_tablespace_name
          FROM sys.dba_segments a,
               sys.dba_tables   b,
               sys.ts$          c
         WHERE a.owner = b.owner
           AND segment_name = table_name
           AND segment_type = 'TABLE'
           AND b.tablespace_name = c.name
        UNION ALL
        SELECT a.owner owner,
               segment_name || '.' || b.partition_name,
               segment_type,
               bytes,
               b.num_rows,
               a.blocks blocks,
               b.empty_blocks empty_blocks,
               a.blocks - b.empty_blocks - 1 hwm,
               decode(round((b.avg_row_len * b.num_rows * (1 + (b.pct_free / 100))) / c.blocksize,
                            0),
                      0,
                      1,
                      round((b.avg_row_len * b.num_rows * (1 + (b.pct_free / 100))) / c.blocksize,
                            0)) + 2 avg_used_blocks,
               round(100 * (nvl(b.chain_cnt,
                                0) / greatest(nvl(b.num_rows,
                                                         1),
                                                     1)),
                     2) chain_per,
               round(100 * (a.extents / a.max_extents),
                     2) allo_extent_per,
               a.extents extents,
               a.max_extents max_extents,
               b.next_extent,
               b.tablespace_name o_tablespace_name
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
           AND a.partition_name = b.partition_name),
       (SELECT tablespace_name f_tablespace_name,
               MAX(bytes) max_free_space
          FROM sys.dba_free_space
         GROUP BY tablespace_name)
 WHERE f_tablespace_name = o_tablespace_name
   AND greatest(round(100 * (nvl(hwm - avg_used_blocks,
                                 0) / greatest(nvl(hwm,
                                                          1),
                                                      1)),
                      2),
                0) > 25
   AND owner = 'LUCIFER'
   AND blocks > 128
 ORDER BY 10 DESC,
          1  ASC,
          2  ASC;