###date
echo "04 begin ..."
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_01_ao.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_01_ao.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_02_role.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_02_role.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_03_pass.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_03_pass.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_04_size.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_04_size.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_05_usize.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_05_usize.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_06_username.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_06_username.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_07_usertime.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_07_usertime.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_08_usertab.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_08_usertabo.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_09_userstat.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_09_userstat.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_10_object.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_10_object.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_11_inv.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_11_inv.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_12_par.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_12_par.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_13_job.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_13_job.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_14_sch.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_14_sch.log 2>/dev/null
su - oracle -c "sh /home/oracle/dbcheck/scripts/04_db_object/04_15_link.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/oracle/dbcheck/log/04_db_object/04_15_link.log 2>/dev/null
echo "04 end ..."
