echo "数据库信息查询 开始 ..."
date
sh /home/oracle/dbcheck/scripts/01_db_info/01_01_os.sh|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_01_os.log 2>/dev/null
sh /home/oracle/dbcheck/scripts/01_db_info/01_02_time.sh|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_02_time.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_03_ver.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_03_ver.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_04_path.sh"|grep -i Patch|grep -v '^$' |sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_04_path.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_05_cre.sh"|grep -v '^$' |sed 's/^[ \t]*//g'> /home/oracle/dbcheck/log/01_db_info/01_05_cre.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_06_start.sh"|grep -v '^$' |sed 's/^[ \t]*//g'> /home/oracle/dbcheck/log/01_db_info/01_06_start.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_07_ins.sh"|grep -v '^$' |sed 's/^[ \t]*//g'> /home/oracle/dbcheck/log/01_db_info/01_07_ins.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_08_char.sh"|grep -v '^$' |sed 's/^[ \t]*//g'> /home/oracle/dbcheck/log/01_db_info/01_08_char.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_09_insname.sh"|grep -v '^$' |sed 's/^[ \t]*//g'> /home/oracle/dbcheck/log/01_db_info/01_09_insname.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_10_dbid.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_10_dbid.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/01_db_info/01_11_port.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/01_db_info/01_11_port.log 2>/dev/null
date
echo "数据库信息查询 结束 ..."
