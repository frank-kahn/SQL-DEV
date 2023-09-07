-- 查看数据库表空间信息
SELECT /*+ NO_CPU_COSTING */
 f.host_name,
 d.dbid,
 f.instance_name,
 SYSDATE,
 d.log_mode,
 a.tablespace_name,
 e1.file_count,
 trunc(a.total) allocated_space_mb,
 trunc(a.total - b.free) used_mb,
 trunc(b.free) free_space_mb,
 round(1 - b.free / a.total,
       4) * 100 "USAGE_%",
 c.autosize autosize_mb,
 round((a.total - b.free) / c.autosize,
       4) * 100 "AUTOUSAGE_%"
  FROM (SELECT tablespace_name,
               SUM(nvl(bytes,
                       2)) / 1024 / 1024 total
          FROM dba_data_files dba_data_files1
         GROUP BY tablespace_name) a,
       (SELECT tablespace_name,
               SUM(nvl(bytes,
                       2)) / 1024 / 1024 free
          FROM dba_free_space
         GROUP BY tablespace_name) b,
       (SELECT tablespace_name,
               COUNT(file_name) file_count
          FROM dba_data_files dba_data_files2
         GROUP BY tablespace_name) e1,
       (SELECT x.tablespace_name,
               SUM(x.autosize) autosize
          FROM (SELECT tablespace_name,
                       CASE
                         WHEN maxbytes / 1024 / 1024 = 0 THEN
                          bytes / 1024 / 1024
                         ELSE
                          maxbytes / 1024 / 1024
                       END autosize
                  FROM dba_data_files dba_data_files3) x
         GROUP BY x.tablespace_name) c,
       v$database d,
       (SELECT utl_inaddr.get_host_address() ip
          FROM dual) e2,
       v$instance f
 WHERE b.tablespace_name = a.tablespace_name
   AND c.tablespace_name = b.tablespace_name
   AND e1.tablespace_name = a.tablespace_name
   AND a.tablespace_name = c.tablespace_name
   AND e1.tablespace_name = b.tablespace_name
   AND e1.tablespace_name = c.tablespace_name
 ORDER BY 13 DESC;