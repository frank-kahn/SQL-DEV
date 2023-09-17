#echo "###redo log切换情况###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set pagesize 100
set heading off
select a_count from (
select to_char(first_time,'YYYY-MM-DD') a_date,
count(*) a_count from gv\$log_history
group by to_char(first_time,'YYYY-MM-DD')
order by 1 desc) where rownum<=5;
exit;
EOF
