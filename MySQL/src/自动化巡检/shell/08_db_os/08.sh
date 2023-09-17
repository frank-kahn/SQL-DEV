echo "08 begin ..."
sh /home/mysql/dbcheck/scripts/08_db_os/08_01_dfh.sh > /home/mysql/dbcheck/log/08_db_os/08_01_dfh.log
sh /home/mysql/dbcheck/scripts/08_db_os/08_02_dfi.sh > /home/mysql/dbcheck/log/08_db_os/08_02_dfi.log
sh /home/mysql/dbcheck/scripts/08_db_os/08_03_mount.sh > /home/mysql/dbcheck/log/08_db_os/08_03_mount.log
sh /home/mysql/dbcheck/scripts/08_db_os/08_04_fstab.sh > /home/mysql/dbcheck/log/08_db_os/08_04_fstab.log
echo "08 end ..."
