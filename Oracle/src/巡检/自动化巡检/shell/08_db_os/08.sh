echo "08 begin ..."
sh /home/oracle/dbcheck/scripts/08_db_os/08_01_df.sh|grep -v '^$'|sed 's/^[ \t]*//g'|awk -F' ' '{print $1,$5,$6}'|grep -v Mounted > /home/oracle/dbcheck/log/08_db_os/08_01_df.log 2>/dev/null
sh /home/oracle/dbcheck/scripts/08_db_os/08_02_mount.sh|grep -v '^$'|sed 's/^[ \t]*//g'|awk -F' ' '{print $1,$5,$6}'|grep -v Mounted > /home/oracle/dbcheck/log/08_db_os/08_02_mount.log 2>/dev/null
sh /home/oracle/dbcheck/scripts/08_db_os/08_03_fstab.sh|grep -v '^$'|sed 's/^[ \t]*//g'|awk -F' ' '{print $1,$5,$6}'|grep -v Mounted > /home/oracle/dbcheck/log/08_db_os/08_03_fstab.log 2>/dev/null
echo "08 end ..."
