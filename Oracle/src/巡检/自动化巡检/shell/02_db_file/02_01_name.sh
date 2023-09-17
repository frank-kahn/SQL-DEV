sqlplus -S "/ as sysdba " << EOF
set linesize 20 
set heading off
select
a.tablespace_name
--a.Total_mb a
--f.Free_mb
--round(a.total_MB-f.free_mb,2) Used_mb
--round((f.free_MB/a.total_MB)*100) "Free"
from
(select tablespace_name, sum(bytes/(1024*1024)) total_MB from dba_data_files group by tablespace_name) a,
(select tablespace_name, round(sum(bytes/(1024*1024))) free_MB from dba_free_space group by tablespace_name) f
WHERE a.tablespace_name = f.tablespace_name(+)
;
exit;
EOF
