#!/bin/bash
# script from www.itpux.com and fgjy,use mysqldump to Full backup mysql data per day!
DataBakDir=/mysql/backup/backup-db
LogOutFile=/mysql/backup/backup-db/bak-db.log
LogErrOutFile=/mysql/backup/backup-db/bak-db-err.log
BinLogBakDir=/mysql/backup/backup-binlog
MyCNF=/mysql/data/3306/my.cnf
mysql_host=192.168.1.51  #根据自己的实际情况设置
mysql_port=3306  #根据自己的实际情况设置
mysql_user=root  #根据自己的实际情况设置
mysql_pass=root  #根据自己的实际情况设置
Date=`date +%Y%m%d`
Begin=`date +"%Y-%m-%d %H:%M:%S"`
cd $DataBakDir
DumpFile="dbbackup-alldb-$Date.sql"
GZDumpFile=dbbackup-alldb-$Date.sql.gz
/mysql/app/mysql/bin/mysqldump -u${mysql_user} -p${mysql_pass} --single-transaction --master-data=2 --routines --flush-logs --flush-privileges --all-databases --log-error=$LogErrOutFile > $DumpFile 
/mysql/app/mysql/bin/mysqldump -u${mysql_user} -p${mysql_pass} --skip-lock-tables --databases performance_schema information_schema sys  | gzip > dbbackup-per-inf-sys-$Date.sql.gz
tar -zcvf $GZDumpFile $DumpFile $MyCNF
Last=`date +"%Y-%m-%d %H:%M:%S"`
#Function export user privileges
mysql_exp_grants()
{  
  mysql -B -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}   $@ -e "SELECT CONCAT(  'SHOW CREATE USER   ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}  -f  $@ | \
  sed 's#$#;#g;s/^\(CREATE USER for .*\)/-- \1 /;/--/{x;p;x;}' 
 
  mysql -B -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}   $@ -e "SELECT CONCAT(  'SHOW GRANTS FOR ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}  -f  $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'   
}  
mysql_exp_grants > ./mysql_exp_grants_out_$Date.sql
echo "data-backup---Start:$Begin;Complete:$Last;$GZDumpFile Out Complete!" >> $LogOutFile
#find $BinLogBakDir -mtime +7 -name "*bin*.*" -exec rm -rf {} \;
find $DataBakDir -mtime +1 -name "*.sql" -exec rm -rf {} \;
find $DataBakDir -mtime +15 -name "*.gz" -exec rm -rf {} \;