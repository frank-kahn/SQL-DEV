/*
配置生产环境的逻辑自动备份策略 
--要求：每天早上5点做逻辑全备，备份文件保留一周。 
*/
export BAKDATE=`date +%Y%m%d` 
export ORACLE_SID=testdb
nohup exp system/oracle compress=n buffer=4096000 feedback=100000 full=y file=/backup/expfull_testdb_$BAKDATE.dmp log=/backup/expfull_testdb_$BAKDATE.log & 
gzip -f /backup/expfull_testdb_$BAKDATE.dmp
find /backup -name expfull_testdb_*.dmp.gz -atime +7 -exec rm -rf {} \;

/*
写进crontab定期自动执行
#chown -R oracle:dba /backup/scripts/expfull_testdb.sh 
#chmod 775 /backup/scripts/expfull_testdb.sh 
#crontab -e 
00 05 * * * su - oracle -c /backup/scripts/expfull_testdb.sh
--分  时  日  月  星期
*/


/*
配置生产环境的逻辑自动备份策略 
--要求：每天晚上20点做逻辑全备，备份文件保留一周。 
*/


source ~/.bash_profile
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
export ORACLE_SID=db01
export BAKDATE=$(date +%Y%m%d)
#exp system/oracle full=y file=/backup/db01_$BAKDATE.dmp log=/backup/db01_$BAKDATE.log buffer=4096000
exp system/oracle owner=scuser file=/backup/db01_$BAKDATE.dmp log=/backup/db01_$BAKDATE.log buffer=4096000
export del_BAKDATE=$(date -d -7day +%Y%m%d)
rm -rf /backup/db01_$del_BAKDATE.dmp
rm -rf /backup/db01_$del_BAKDATE.log

--将以上写进crontab定期执行：
* 20 * * * su - oracle -c /soft/db01_exp_full.sh


