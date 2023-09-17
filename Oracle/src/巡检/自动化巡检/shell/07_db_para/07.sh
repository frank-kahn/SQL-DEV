echo "07 begin ..."
su - oracle -c "sh /home/oracle/dbcheck/scripts/07_db_para/07_01_para.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/07_db_para/07_01_para.log 2>/dev/null
echo "07 end ..."
