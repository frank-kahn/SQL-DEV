echo "05 begin ..."
sh /home/mysql/dbcheck/scripts/05_db_bakchk/05_01_cron.sh > /home/mysql/dbcheck/log/05_db_bakchk/05_01_cron.log
sh /home/mysql/dbcheck/scripts/05_db_bakchk/05_02_baksize.sh > /home/mysql/dbcheck/log/05_db_bakchk/05_02_baksize.log
sh /home/mysql/dbcheck/scripts/05_db_bakchk/05_03_bakcheck.sh > /home/mysql/dbcheck/log/05_db_bakchk/05_03_bakcheck.log

echo "05 end ..."
