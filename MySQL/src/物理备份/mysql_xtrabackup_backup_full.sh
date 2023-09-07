#!/bin/bash
# script from www.itpux.com and fgedu,use xtrbackup to Full backup mysql data per day!
BAKDIR=/mysql/backup/backup-db
XTRABACKUPDIR=/mysql/app/xtrabackup/bin/xtrabackup
BAKFILEPRE=xtrfullbackup
BAKFILE=$BAKDIR/$BAKFILEPRE-`date +%Y%m%d`
LOGFILE=$BAKDIR/$BAKFILEPRE-`date +%Y%m%d`.log
BAKDIR1=$BAKDIR/$BAKFILEPRE
BAKDIR2=$BAKFILE
REMOTE_HOST=192.168.1.51
REMOTE_BAKDIR=/mysql/backup/backup-db
MYCNF=/mysql/data/3306/my.cnf
BAKMYCNF=$BAKDIR/my-`date +%Y%m%d`.cnf
USER=backup
PWD=backup
PARALLEL=2 
#innobackupex --defaults-file=$MYCNF --user=$USER --password=$PWD --stream=tar $BAKDIR 2> $LOGFILE |ssh $REMOTE_HOST "gzip ->$REMOTE_BAKDIR/$BAKFILE.tar.gz"
$XTRABACKUPDIR --defaults-file=$MYCNF  --user=$USER --password=$PWD --backup --parallel=$PARALLEL --stream=tar --target-dir=$BAKDIR1  1> $BAKDIR2.tar 2> $LOGFILE
gzip -c $BAKDIR2.tar > $BAKDIR2.tar.gz
cp $MYCNF $BAKMYCNF
# check backup log
CHECKOK=`tail -1 $LOGFILE | grep "completed OK\!" | wc -l`
if [ $CHECKOK -ne 1 ]
then
  echo "[ WARNING ] Backup failed!"
  exit
fi
#ssh $REMOTE_HOST "find $REMOTE_BAKDIR/$BAKFILEPRE* -mtime +14 -type f -maxdepth 1 | xargs rm -rf {}"
find $BAKDIR -mtime +1 -name "$BAKFILEPRE*.tar" -exec rm -f {} \;
find $BAKDIR -mtime +15 -name "$BAKFILEPRE*.gz" -exec rm -f {} \;
find $BAKDIR -mtime +15 -name "$BAKFILEPRE*.log" -exec rm -f {} \;
find $BAKDIR -mtime +3 -name "my-*.cnf" -exec rm -f {} \;
