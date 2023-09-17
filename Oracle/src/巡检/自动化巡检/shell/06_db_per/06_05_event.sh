#echo "###等待事件###"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
set line 200
col cou for a20 for 9999
col event for a30 
set heading off
set feedback off
select * from (select count(*) cou,event from dba_hist_active_sess_history where event is not null group by event order by 1 desc) where rownum<=10;
exit;
EOF