#!/bin/bash
# #script from www.itpux.com and fgjy,use cp to backup mysql binlog everyday!
BinLogBakDir=/mysql/backup/backup-binlog
BinLogDir=/mysql/log/3306/binlog                                
LogOutFile=/mysql/backup/backup-binlog/bak-bin.log
/mysql/app/mysql/bin/mysqladmin -uroot -proot -h192.168.1.51 flush-logs
BinIndexFile=/mysql/log/3306/binlog/itpuxdb-binlog.index
NextLogFile=`tail -n 1 $BinIndexFile`
LogCounter=`wc -l $BinIndexFile |awk '{print $1}'`
NextNum=0
#这个for循环用于比对$Counter,$NextNum这两个值来确定文件是不是存在或最新的
echo "--------------------------------------------------------------------" >> $LogOutFile
echo binlog-backup---`date +"%Y-%m-%d %H:%M:%S"` Bakup Start... >> $LogOutFile
for binfile in `cat $BinIndexFile`
do
    base=`basename $binfile`
    #basename用于截取mysql-bin.00000*文件名，去掉./mysql-bin.000005前面的./
    NextNum=`expr $NextNum + 1`
    if [ $NextNum -eq $LogCounter ]
    then
        echo $base skip! >> $LogOutFile
    else
        dest=$BinLogBakDir/$base
        if(test -e $dest)
        #test -e用于检测目标文件是否存在，存在就写exist!到$LogFile去
        then
            echo $base exist! >> $LogOutFile
        else
            cp $BinLogDir/$base $BinLogBakDir
            echo $base copying >> $LogOutFile
         fi
     fi
done
echo binlog-backup---`date +"%Y-%m-%d %H:%M:%S"` Bakup Complete! Next LogFile is: $NextLogFile  >> $LogOutFile
find $BinLogBakDir -mtime +30 -name "*binlog.**" -exec rm -rf {} \;