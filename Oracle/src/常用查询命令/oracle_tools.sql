-- 查看数据库用户profile配置信息
SELECT profile,
       resource_name,
       resource_type,
       LIMIT
  FROM dba_profiles
 WHERE profile = 'DEFAULT';

-- 查看数据库asm磁盘组信息
SELECT NAME,
       block_size,
       state,
       TYPE,
       total_mb       AS total_mb,
       usable_file_mb AS free_mb
  FROM v$asm_diskgroup;

-- 查看数据库scn信息  
SELECT to_char(created,
               'yyyy-mm-dd hh24:mi:ss') TIME,
       dbms_flashback.get_system_change_number scn,
       round(((((((to_number(to_char(SYSDATE,
                                     'YYYY')) - 1988) * 12 * 31 * 24 * 60 * 60) +
             ((to_number(to_char(SYSDATE,
                                     'MM')) - 1) * 31 * 24 * 60 * 60) +
             (((to_number(to_char(SYSDATE,
                                      'DD')) - 1)) * 24 * 60 * 60) +
             (to_number(to_char(SYSDATE,
                                    'HH24')) * 60 * 60) + (to_number(to_char(SYSDATE,
                                                                                 'MI')) * 60) +
             (to_number(to_char(SYSDATE,
                                    'SS')))) * (16 * 1024)) - dbms_flashback.get_system_change_number) / (16 * 1024 * 60 * 60 * 24)),
             2) headroom
  FROM v$database;

-- 收集指定用户指定表统计信息       
BEGIN
  dbms_stats.gather_table_stats(ownname          => 'LUCIFER',
                                tabname          => 'LUCIFER',
                                estimate_percent => 100,
                                method_opt       => 'FOR ALL COLUMNS SIZE 1',
                                cascade          => TRUE,
                                no_invalidate    => FALSE);
END;
/
                   
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
                                    
-- 执行最慢的sql语句信息    
SELECT *
  FROM (SELECT sa.sql_id,
               sa.sql_text,
               sa.sql_fulltext,
               sa.executions,
               round(sa.elapsed_time / 1000000,
                     2) total_time,
               round(sa.elapsed_time / 1000000 / sa.executions,
                     2) sec_time,
               u.username
          FROM v$sqlarea sa
          LEFT JOIN dba_users u
            ON sa.parsing_user_id = u.user_id
           AND u.account_status = 'OPEN'
         WHERE sa.executions > 0
           AND username NOT IN ('SYSTEM',
                                'SYS',
                                'ORACLE_OCM',
                                'DBSNMP',
                                'APEX_030200')
         ORDER BY (sa.elapsed_time / sa.executions) DESC)
 WHERE rownum <= 50;
 
-- 查询sql执行计划  
SELECT *
  FROM TABLE(dbms_xplan.display_cursor('g4y6nw3tts7cc',
                                       NULL,
                                       'ADVANCED ALLSTATS LAST PEEKED_BINDS'));
                                       
-- 阻塞锁信息查询        
       SELECT rpad('+',
            LEVEL,
            '-') || sid || ' ' || sess.module session_detail,
       sid,
       serial#,
       'alter system kill session ''' || sid || ',' || serial# || ',@' || sess.inst_id || ''' immediate;' AS kill_sql,
       blocker_sid,
       sess.inst_id,
       wait_event_text,
       object_name,
       rpad(' ',
            LEVEL) || sql_text sql_text
  FROM v$wait_chains c
  LEFT OUTER JOIN dba_objects o
    ON (row_wait_obj# = object_id)
  JOIN gv$session sess
 USING (sid)
  LEFT OUTER JOIN v$sql SQL
    ON (sql.sql_id = sess.sql_id AND sql.child_number = sess.sql_child_number)
CONNECT BY PRIOR sid = blocker_sid
       AND PRIOR sess_serial# = blocker_sess_serial#
       AND PRIOR instance = blocker_instance
 START WITH blocker_is_valid = 'FALSE';
 
-- 数据库一周性能运行情况  

SELECT s.instance_number,
       s.endsnap_id,
       s.snap_date,
       decode(s.redosize,
              NULL,
              '--shutdown or end --',
              s.currtime) "TIME",
       to_char(round(s.seconds / 60,
                     2)) "elapse(min)",
       round(t.db_time / 1000000 / 60,
             2) "db time(min)",
       s.redosize reodo,
       round(s.redosize / s.seconds,
             2) "redo/s",
       s.logicalreads logical,
       round(s.logicalreads / s.seconds,
             2) "logical/s",
       physicalreads physical,
       round(s.physicalreads / s.seconds,
             2) "phy/s",
       s.executes execs,
       round(s.executes / s.seconds,
             2) "execs/s",
       s.parse,
       round(s.parse / s.seconds,
             2) "parse/s",
       s.hardparse,
       round(s.hardparse / s.seconds,
             2) "hardparse/s",
       s.transactions trans,
       round(s.transactions / s.seconds,
             2) "trans/s"
  FROM (SELECT instance_number,
               curr_redo - last_redo redosize,
               curr_logicalreads - last_logicalreads logicalreads,
               curr_physicalreads - last_physicalreads physicalreads,
               curr_executes - last_executes executes,
               curr_executes - last_parse parse,
               curr_hardparse - last_hardparse hardparse,
               curr_transactions - last_transactions transactions,
               round(((currtime + 0) - (lasttime + 0)) * 3600 * 24,
                     0) seconds,
               to_char(currtime,
                       'yyyy-mm-dd') snap_date,
               to_char(currtime,
                       'hh24:mi:ss') currtime,
               currsnap_id endsnap_id,
               to_char(startup_time,
                       'yyyy-mm-dd hh24:mi:ss') startup_time
          FROM (SELECT a.instance_number,
                       a.redo last_redo,
                       a.logicalreads last_logicalreads,
                       a.physicalreads last_physicalreads,
                       a.executes last_executes,
                       a.parse last_parse,
                       a.hardparse last_hardparse,
                       a.transactions last_transactions,
                       lead(a.redo,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_redo,
                       lead(a.logicalreads,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_logicalreads,
                       lead(a.physicalreads,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_physicalreads,
                       lead(a.executes,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_executes,
                       lead(a.parse,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_parse,
                       lead(a.hardparse,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_hardparse,
                       lead(a.transactions,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) curr_transactions,
                       b.end_interval_time lasttime,
                       lead(b.end_interval_time,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) currtime,
                       lead(b.snap_id,
                            1,
                            NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) currsnap_id,
                       b.startup_time
                  FROM (SELECT snap_id,
                               dbid,
                               instance_number,
                               SUM(decode(stat_name,
                                          'redo size',
                                          VALUE,
                                          0)) redo,
                               SUM(decode(stat_name,
                                          'session logical reads',
                                          VALUE,
                                          0)) logicalreads,
                               SUM(decode(stat_name,
                                          'physical reads',
                                          VALUE,
                                          0)) physicalreads,
                               SUM(decode(stat_name,
                                          'execute count',
                                          VALUE,
                                          0)) executes,
                               SUM(decode(stat_name,
                                          'parse count (total)',
                                          VALUE,
                                          0)) parse,
                               SUM(decode(stat_name,
                                          'parse count (hard)',
                                          VALUE,
                                          0)) hardparse,
                               SUM(decode(stat_name,
                                          'user rollbacks',
                                          VALUE,
                                          'user commits',
                                          VALUE,
                                          0)) transactions
                          FROM dba_hist_sysstat
                         WHERE stat_name IN ('redo size',
                                             'session logical reads',
                                             'physical reads',
                                             'execute count',
                                             'user commits',
                                             'parse count (hard)',
                                             'parse count (total)')
                         GROUP BY snap_id,
                                  dbid,
                                  instance_number) a,
                       dba_hist_snapshot b
                 WHERE a.snap_id = b.snap_id
                   AND a.dbid = b.dbid
                   AND a.instance_number = b.instance_number
                 ORDER BY end_interval_time)) s,
       (SELECT b.instance_number,
               a.value,
               lead(a.value,
                    1,
                    NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) - a.value db_time,
               lead(b.snap_id,
                    1,
                    NULL) over(PARTITION BY b.instance_number ORDER BY b.end_interval_time) endsnap_id
          FROM dba_hist_sys_time_model a,
               dba_hist_snapshot       b
         WHERE a.snap_id = b.snap_id
           AND a.dbid = b.dbid
           AND a.instance_number = b.instance_number
           AND a.stat_name = 'DB time') t
 WHERE s.endsnap_id = t.endsnap_id
   AND s.instance_number = t.instance_number
 ORDER BY s.snap_date DESC,
          TIME        DESC;
		  
-- 根据系统进程查看该进程信息    
SELECT '实例             :' || s.inst_id || chr(10) || '用户名           :' || s.username || chr(10) || '对象名           :' || s.schemaname || chr(10) ||
       '系统用户         :' || s.osuser || chr(10) || '进程名           :' || s.program || chr(10) || '进程号           :' || p.spid || chr(10) ||
       'SERIAL#          :' || s.serial# || chr(10) || '会话Kill信息     :' || 'alter system kill session ' || s.sid || ',' || s.serial# || ',@' ||
       s.inst_id || ' immediate;' || chr(10) || '类型             :' || s.type || chr(10) || '终端             :' || s.terminal || chr(10) ||
       'SQL_ID           :' || q.sql_id
  FROM gv$session s,
       gv$process p,
       v$sql      q
 WHERE s.paddr = p.addr
   AND p.spid = '3076'
   AND s.sql_id = q.sql_id(+);
                          
-- Oracle DataGuard状态   
SELECT *
  FROM (SELECT rownum,
               NAME,
               creator,
               sequence#,
               applied,
               completion_time
          FROM v$archived_log
         ORDER BY completion_time DESC)
 WHERE rownum < 10;
 
-- 创建awr快照   
BEGIN
  dbms_workload_repository.create_snapshot();
END;
/
                                          
-- 数据库会话活动进度信息 
SELECT inst_id,
       sid,
       username,
       sql_id,
       opname,
       start_time,
       elapsed_seconds,
       time_remaining,
       round(sofar * 100 / totalwork,
             2) exec_pct,
       CONTEXT dfo
  FROM gv$session_longops
 WHERE time_remaining > 0
 ORDER BY elapsed_seconds DESC;
                                               
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
                                                                         
-- 查看redo日志切换频率  

SELECT DAY,
       to_char(SUM(decode(h,
                          '00',
                          t,
                          0))) AS "00",
       to_char(SUM(decode(h,
                          '01',
                          t,
                          0))) AS "01",
       to_char(SUM(decode(h,
                          '02',
                          t,
                          0))) AS "02",
       to_char(SUM(decode(h,
                          '03',
                          t,
                          0))) AS "03",
       to_char(SUM(decode(h,
                          '04',
                          t,
                          0))) AS "04",
       to_char(SUM(decode(h,
                          '05',
                          t,
                          0))) AS "05",
       to_char(SUM(decode(h,
                          '06',
                          t,
                          0))) AS "06",
       to_char(SUM(decode(h,
                          '07',
                          t,
                          0))) AS "07",
       to_char(SUM(decode(h,
                          '08',
                          t,
                          0))) AS "08",
       to_char(SUM(decode(h,
                          '09',
                          t,
                          0))) AS "09",
       to_char(SUM(decode(h,
                          '10',
                          t,
                          0))) AS "10",
       to_char(SUM(decode(h,
                          '11',
                          t,
                          0))) AS "11",
       to_char(SUM(decode(h,
                          '12',
                          t,
                          0))) AS "12",
       to_char(SUM(decode(h,
                          '13',
                          t,
                          0))) AS "13",
       to_char(SUM(decode(h,
                          '14',
                          t,
                          0))) AS "14",
       to_char(SUM(decode(h,
                          '15',
                          t,
                          0))) AS "15",
       to_char(SUM(decode(h,
                          '16',
                          t,
                          0))) AS "16",
       to_char(SUM(decode(h,
                          '17',
                          t,
                          0))) AS "17",
       to_char(SUM(decode(h,
                          '18',
                          t,
                          0))) AS "18",
       to_char(SUM(decode(h,
                          '19',
                          t,
                          0))) AS "19",
       to_char(SUM(decode(h,
                          '20',
                          t,
                          0))) AS "20",
       to_char(SUM(decode(h,
                          '21',
                          t,
                          0))) AS "21",
       to_char(SUM(decode(h,
                          '22',
                          t,
                          0))) AS "22",
       to_char(SUM(decode(h,
                          '23',
                          t,
                          0))) AS "23"
  FROM (SELECT to_char(first_time,
                       'YYYY-MM-DD') DAY,
               to_char(first_time,
                       'HH24') h,
               COUNT(1) t
          FROM v$log_history
         WHERE first_time > SYSDATE - 15
         GROUP BY to_char(first_time,
                          'YYYY-MM-DD'),
                  to_char(first_time,
                          'HH24')
         ORDER BY 1)
 GROUP BY DAY
 ORDER BY DAY DESC;
                                  
-- 查看游标使用情况   

SELECT 'session_cached_cursors' parameter,
       lpad(VALUE,
            5) VALUE,
       decode(VALUE,
              0,
              ' n/a',
              to_char(100 * used / VALUE,
                      '990') || '%') usage
  FROM (SELECT MAX(s.value) used
          FROM v$statname n,
               v$sesstat  s
         WHERE n.name = 'session cursor cache count'
           AND s.statistic# = n.statistic#),
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'session_cached_cursors')
UNION ALL
SELECT 'open_cursors',
       lpad(VALUE,
            5),
       to_char(100 * used / VALUE,
               '990') || '%'
  FROM (SELECT MAX(SUM(s.value)) used
          FROM v$statname n,
               v$sesstat  s
         WHERE n.name IN ('opened cursors current')
           AND s.statistic# = n.statistic#
         GROUP BY s.sid),
       (SELECT VALUE
          FROM v$parameter
         WHERE NAME = 'open_cursors');
