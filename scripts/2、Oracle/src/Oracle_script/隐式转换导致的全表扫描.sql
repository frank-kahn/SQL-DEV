select * from
(
select PARSING_SCHEMA_NAME,s.sql_id, s.sql_text,s.EXECUTIONS,
  fetches,
  rows_processed,
  rows_processed/nullif(fetches,0) rows_per_fetch,
  ROUND(cpu_time/NULLIF(executions,0)/1000000,3)     cpu_sec_exec,
  ROUND(elapsed_time/NULLIF(executions,0)/1000000,3) ela_sec_exec,
  ROUND(buffer_gets/NULLIF(executions,0),3)  lios_per_exec,
  ROUND(disk_reads/NULLIF(executions,0),3)   pios_per_exec,
  ROUND(cpu_time/1000000,3) total_cpu_sec,
  ROUND(elapsed_time/1000000,3) total_ela_sec,
  user_io_wait_time/1000000 total_iowait_sec,
  buffer_gets total_LIOS,
  disk_reads total_pios
  from v$sqlarea s
 where s.sql_id in
       (select p.sql_id
          from v$sql_plan p
         where p.OPERATION = 'TABLE ACCESS'
           and p.OPTIONS = 'FULL'
           and p.FILTER_PREDICATES like '%INTERNAL_FUNCTION%')
       and PARSING_SCHEMA_NAME not in('SYS')
       order by elapsed_time desc)
       where rownum<=50;
	   
	   
---------------------------------------------------------------------------	 

COLUMN large_table_scans FORMAT 999,999,999,999,999 HEADING 'Large Table Scans' ENTMAP off
COLUMN small_table_scans FORMAT 999,999,999,999,999 HEADING 'Small Table Scans' ENTMAP off
COLUMN pct_large_scans HEADING 'Pct. Large Scans' ENTMAP off

SELECT a.value large_table_scans,
       b.value small_table_scans,
       '' || ROUND(100 * a.value /
                    DECODE((a.value + b.value), 0, 1, (a.value + b.value)),
                    2) || '%
' pct_large_scans
  FROM v$sysstat a, v$sysstat b
 WHERE a.name = 'table scans (long tables)'
   AND b.name = 'table scans (short tables)';

