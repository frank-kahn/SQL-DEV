echo "数据库文件查询 开始 ..."
date
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_01_name.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_01_name.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_02_tabstat.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_02_tabstat.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_03_total.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_03_total.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_04_use.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_04_use.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_05_file.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_05_file.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_06_auto.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_06_auto.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_07_max.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_07_max.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_08_state.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_08_state.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_09_name.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_09_name.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_10_roll.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_10_roll.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_11_temp.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_11_temp.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_12_con.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_12_con.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_13_redo.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_13_redo.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_14_redo.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_14_redo.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/02_db_file/02_15_swi.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/02_db_file/02_15_swi.log 2>/dev/null
echo "查询结束 ..."
