echo "03 RAC集群检查 开始 ..."
#date
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_01_asm.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_01_asm.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_02_asmdisk.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_02_asmdisk.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_03_ocr.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_03_ocr.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_04_ocrcheck.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_04_ocrcheck.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_05_ocrbak.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_05_ocrbak.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_06_vote.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_06_vote.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_07_clu.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_07_clu.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_08_res.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_08_res.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_09_scan.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_09_scan.log 2>/dev/null
su - grid -c "sh /home/grid/dbcheck/scripts/03_db_rac/03_10_lis.sh"|grep -v '^$'|sed 's/^[ \t]*//g' > /home/grid/dbcheck/log/03_db_rac/03_10_lis.log 2>/dev/null
echo "03执行完成 ..."
