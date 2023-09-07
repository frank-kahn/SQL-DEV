--一键获取收缩数据文件脚本
SELECT a.tablespace_name,
       file_name,
       blocks,
       c.value "Block_size",
       ceil((nvl(hwm,
                 1) * c.value) / 1024 / 1024) "HWM",
       ceil(blocks * c.value / 1024 / 1024) "Currentsize(Mb)",
       ceil(blocks * c.value / 1024 / 1024 - (nvl(hwm,
                                                   1) * c.value) / 1024 / 1024) "Reducesize(Mb)",
       'alter database datafile ''' || file_name || ''' resize ' ||
       (ceil((nvl(hwm,
                 1) * c.value) / 1024 / 1024) + 50) || 'M;'
  FROM dba_data_files a,
       (SELECT file_id,
               MAX(block_id + blocks - 1) hwm
          FROM dba_extents
         GROUP BY file_id) b,
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'db_block_size') c
 WHERE a.file_id = b.file_id(+)
   AND a.status != 'INVALID'
   AND a.online_status != 'OFFLINE'
   AND a.tablespace_name NOT IN ('UNDOTBS1',
                                 'UNDOTBS2',
                                 'SYSTEM',
                                 'SYSAUX',
                                 'USERS')
 ORDER BY 7 DESC;
