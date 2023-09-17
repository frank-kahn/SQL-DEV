echo "04 begin ..."
sh /home/mysql/dbcheck/scripts/04_db_object/04_01_user.sh > /home/mysql/dbcheck/log/04_db_object/04_01_user.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_02_tablemb.sh > /home/mysql/dbcheck/log/04_db_object/04_02_tablemb.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_03_indexmb.sh > /home/mysql/dbcheck/log/04_db_object/04_03_indexmb.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_04_creuser.sh > /home/mysql/dbcheck/log/04_db_object/04_04_creuser.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_05_tab.sh > /home/mysql/dbcheck/log/04_db_object/04_05_tab.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_06_view.sh > /home/mysql/dbcheck/log/04_db_object/04_06_view.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_07_trigger.sh > /home/mysql/dbcheck/log/04_db_object/04_07_tirgger.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_08_proc.sh > /home/mysql/dbcheck/log/04_db_object/04_08_proc.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_09_part.sh > /home/mysql/dbcheck/log/04_db_object/04_09_part.log
sh /home/mysql/dbcheck/scripts/04_db_object/04_10_engine.sh > /home/mysql/dbcheck/log/04_db_object/04_10_engine.log
echo "04 end ..."


