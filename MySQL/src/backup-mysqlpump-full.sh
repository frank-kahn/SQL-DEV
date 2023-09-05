#!/bin/bash
# script from www.itpux.com and fgjy,use mysqlpump to Full backup mysql data per day!
DataBakDir=/mysql/backup/backup-db
MySQLPUMPDIR=/mysql/app/mysql/bin/mysqlpump
LogOutFile=/mysql/backup/backup-db/bak-db.log
LogErrOutFile=/mysql/backup/backup-db/bak-err.log
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
GZDumpFile=dbbackup-alldb-$Date.sql.tar.gz
#mysqlpump -u${mysql_user} -p${mysql_pass} --single-transaction --default-character-set=utf8 --default-parallelism=2 --include-databases=itpux,itpuxdb,itpuxdb1> $DumpFile 
$MySQLPUMPDIR -u${mysql_user} -p${mysql_pass} --single-transaction --default-character-set=utf8 --default-parallelism=2 --all-databases --exclude-databases=performance_schema,information_schema,sys,mysql > $DumpFile 2> $LogErrOutFile
$MySQLPUMPDIR u${mysql_user} -p${mysql_pass} --single-transaction --default-character-set=utf8 --default-parallelism=2 -B performance_schema information_schema sys mysql  | gzip > dbbackup-per-inf-sys-mysql-$Date.sql.gz
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
find $DataBakDir -mtime +1 -name "*.sql" -exec rm -rf {} \;
find $DataBakDir -mtime +15 -name "*.gz" -exec rm -rf {} \;
