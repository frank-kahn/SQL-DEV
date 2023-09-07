#!/bin/bash
# script from www.itpux.com and fgedu,use mysqlbackup to Full backup mysql data per day!
BAKDIR=/mysql/backup/backup-db
BAKTEMP=/mysql/backup/backup-tmp
MEBBIN=/mysql/app/mysqlbackup/bin/mysqlbackup
BAKFILEPRE=fullbackup
BAKFILE=$BAKDIR/$BAKFILEPRE-`date +%Y%m%d`
LOGFILE=$BAKDIR/$BAKFILEPRE-`date +%Y%m%d`.log
REMOTE_HOST=192.168.1.51
REMOTE_BAKDIR=/mysql/backup/backup-db
MYCNF=/mysql/data/3306/my.cnf
BAKMYCNF=$BAKDIR/my-`date +%Y%m%d`.cnf
USER=backup
PWD=backup
#--read-threads=2 
#--write-threads=2  
#--process-threads=8 
echo "---------------------------------" > $LOGFILE
echo "mysqlbackup backup start......" >> $LOGFILE
echo "---------------------------------" >> $LOGFILE
$MEBBIN --defaults-file=$MYCNF  --user=$USER --password=$PWD --backup-image=$BAKFILE.mbi --with-timestamp backup-to-image --backup-dir=$BAKTEMP 2>> $LOGFILE
echo "---------------------------------" >> $LOGFILE
echo "mysqlbackup validate start....." >> $LOGFILE
echo "---------------------------------" >> $LOGFILE
$MEBBIN --backup-image=$BAKFILE.mbi  validate 2>> $LOGFILE
gzip -c $BAKFILE.mbi > $BAKFILE.mbi.gz
cp $MYCNF $BAKMYCNF
# check backup log
CHECKOK=`tail -10 $LOGFILE | grep "mysqlbackup completed OK\!" | wc -l`
if [ $CHECKOK -ne 1 ]
then
  echo "[ WARNING ] Backup failed!"
  exit
fi
CHECKOK=`cat $LOGFILE | egrep  'error|ERROR' | wc -l`
if [ $CHECKOK -gt 0 ]
then
  echo "[ WARNING ]  The backup existing problems, please check!"
  exit
fi
#ssh $REMOTE_HOST "find $REMOTE_BAKDIR/$BAKFILEPRE* -mtime +14 -type f -maxdepth 1 | xargs rm -rf {}"
find $BAKDIR -mtime +1 -name "$BAKFILEPRE*.mbi" -exec rm -f {} \;
find $BAKDIR -mtime +15 -name "$BAKFILEPRE*.gz" -exec rm -f {} \;
find $BAKDIR -mtime +15 -name "$BAKFILEPRE*.log" -exec rm -f {} \;
find $BAKDIR -mtime +3 -name "my-*.cnf" -exec rm -f {} \;
