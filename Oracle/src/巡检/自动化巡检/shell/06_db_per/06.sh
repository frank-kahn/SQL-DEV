echo "06 begin ..."
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_01_session.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_01_session.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_02_res.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_02_res.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_03_task.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_03_task.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_04_sga.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_04_sga.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_05_event.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_05_event.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_06_free.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_06_free.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_07_memuse.sh"|grep -v '^$'|grep -v 'USE'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_07_memuse.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/06_db_per/06_08_cpuuse.sh"|grep -v '^$'|grep -v 'USE'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/06_db_per/06_08_cpuuse.log 2>/dev/null
echo "06 end ..."
