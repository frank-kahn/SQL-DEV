echo "03 begin ..."
sh /home/mysql/dbcheck/scripts/03_db_master/03_01_slave_io.sh > /home/mysql/dbcheck/log/03_db_master/03_01_slave_io.log
sh /home/mysql/dbcheck/scripts/03_db_master/03_02_slave_sql.sh > /home/mysql/dbcheck/log/03_db_master/03_02_slave_sql.log
sh /home/mysql/dbcheck/scripts/03_db_master/03_03_behind.sh > /home/mysql/dbcheck/log/03_db_master/03_03_behind.log
sh /home/mysql/dbcheck/scripts/03_db_master/03_04_semi.sh > /home/mysql/dbcheck/log/03_db_master/03_04_semi.log
echo "03 end ..."
