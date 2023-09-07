-- 查看数据库asm磁盘组信息
SELECT NAME,
       block_size,
       state,
       TYPE,
       total_mb       AS total_mb,
       usable_file_mb AS free_mb
  FROM v$asm_diskgroup;