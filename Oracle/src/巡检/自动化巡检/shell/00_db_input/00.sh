#!/bin/bash
echo "开始执行脚本 ..."
echo "开始执行01脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_01_master.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_01_master.log 
echo "开始执行02脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_02_slave.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_02_slave.log 
echo "开始执行03脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_03_vip.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_03_vip.log 
echo "开始执行04脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_04_arc.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_04_arc.log
echo "开始执行05脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_05_name.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_05_name.log
echo "开始执行06脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_06_time.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_06_time.log
echo "开始执行07脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_07_title.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_07_title.log
echo "开始执行08脚本 ..."
sh /home/oracle/dbcheck/scripts/00_db_input/00_08_word.sh|grep -v '^$' > /home/oracle/dbcheck/log/00_db_input/00_08_word.log
echo "脚本执行结束 ..."
