/*
配置生产环境的逻辑自动备份策略 
--要求：每天晚上20点做逻辑全备，备份文件保留一周。 
*/


create directory backup_dir as '/backup';
grant read,write on directory backup_dir to system;
grant create any directory to system;

vi expdpfull_auto_backup.sh 

export BAKDATE=`date +%Y%m%d`
nohup expdp system/oracle directory=itpuxbak_dir dumpfile=expdp_full_testdb.$BAKDATE.%U.dmp logfile=expdp_full_testdb.$BAKDATE.log full=y parallel=4 &
find /backup -name expdp_full_testdb.*.dmp -atime +7 -exec rm -rf {} \;

#chown -R oracle:dba expdpfull_auto_backup.sh
#chmod -R 775 expdpfull_auto_backup.sh
#crontab -e 0 20 * * * su - oracle -c /backup/scripts/expdpfull_auto_backup.sh


