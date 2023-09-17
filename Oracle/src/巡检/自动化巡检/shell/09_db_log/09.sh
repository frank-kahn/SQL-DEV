echo "09 begin ..."
sh /home/oracle/dbcheck/scripts/09_db_log/09_01_log.sh|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/09_db_log/09_01_log.log 2>/dev/null
sh /home/oracle/dbcheck/scripts/09_db_log/09_02_message.sh|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/09_db_log/09_02_message.log 2>/dev/null
echo "09 end ..."
