echo "05 begin ..."
su - oracle -c "sh /home/oracle/dbcheck/scripts/05_db_bakchk/05_01_fullbak.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/05_db_bakchk/05_01_fullbak.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/05_db_bakchk/05_02_levelbak.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/05_db_bakchk/05_02_levelbak.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/05_db_bakchk/05_03_archbak.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/05_db_bakchk/05_03_archbak.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/05_db_bakchk/05_04_rman.sh"|grep -v '^$'|grep CONFIGURE|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/05_db_bakchk/05_04_rman.log 2>/dev/null
echo "05 end ..."
