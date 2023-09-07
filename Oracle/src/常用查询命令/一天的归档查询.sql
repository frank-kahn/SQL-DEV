--一天的归档
select a.f_time "DATE",
       a.thread#,
       ceil(sum(a.blocks * a.block_size) / 1024 / 1024 / 1024) "ARCHIVELOGS PER DAY(G)",
       ceil(sum(a.blocks * a.block_size) / 1024 / 1024 / 24) "ARCHIVELOGS PER HOUR(M)"
  from (select distinct sequence#,
                        thread#,
                        blocks,
                        block_size,
                        to_char(first_time, 'yyyy/mm/dd') f_time
          from v$archived_log) a 
 group by a.f_time, a.thread#
 order by 1;

Select to_char(completion_time,'yyyy-mm-dd') as date1,count(0) as cnt,round(sum((blocks *block_size)/1024/1024/1024)) as GB from v$archived_log
group by to_char(completion_time,'yyyy-mm-dd') order by date1 desc;
