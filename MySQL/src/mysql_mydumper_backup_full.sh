#!/bin/bash
# script from www.itpux.com and fgedu,use mydumper to Full backup mysql data per day!
# 数据库分开目录备份
#set parameter 
now_date=`date +%Y%m%d%H%M`
dir_date=`date +%Y%m%d`
MyCNF=/mysql/data/3306/my.cnf
mydumper=/usr/local/bin/mydumper  #根据自己的实际情况设置
dirbackup=/mysql/backup/backup-db
mysqlbin=/mysql/app/mysql/bin/mysql
dir_backup=$dirbackup/fullbackup$dir_date  #根据自己的实际情况设置
OutLogFile=mysql_mydumper_backup_full.out #备份过程中输出的日志文件名,与crontab里面相同
mysql_host=192.168.1.51  #根据自己的实际情况设置
mysql_port=3306  #根据自己的实际情况设置
mysql_user=root  #根据自己的实际情况设置
mysql_pass=root  #根据自己的实际情况设置
 
echo "--------------------------------------------------------"
echo "     备份任务开始: `date +%F' '%T' '%w`" 
echo "--------------------------------------------------------"

if [ ! -d $dir_backup ]; then
  echo -e "\e[1;31m 保存备份的主目录:$dir_backup不存在,将自动新建. \e[0m"
  mkdir -p ${dir_backup}
fi
 

fgedudate_01="fgedudate01.`date +%y%m%d%h%m%s`.txt"
schema_fgedu01="select schema_name from information_schema.schemata ;"
$mysqlbin -h${mysql_host} -P${mysql_port}  -u${mysql_user} -p${mysql_pass} -e"${schema_fgedu01}" >${fgedudate_01}
  echo -e "\e[1;31m script from www.itpux.com and fgedu,use mydumper to Full backup mysql data per day!. \e[0m"
echo -e "\e[1;31m The databases name in current instance is: \e[0m"
awk 'NR==2,NR==0 { print $1}'  ${fgedudate_01}
echo "                          "
 
#Get the current script path and create a file named database.list 
#in order to save the  backup  databases name.
filepath=$(cd "$(dirname "$0")"; pwd)
if [ ! -s "${filepath}/database.list" ];then 
    echo "将在当前目录下新建databases.list."
    touch ${filepath}/database.list
    echo "#Each line is stored a valid database name">${filepath}/database.list
    chmod 700 ${filepath}/database.list
 
fi
#1.优化后默认备份所有的数据库。
#2.优化前读取当前目录下database.list文件,备份部分数据库，如果database.list为空,则执行全备或备份指定的个别数据库

#Remove the comment line
awk 'NR==2,NR==0 { print $1}' ${filepath}/database.list> ${filepath}/tmpdatabases.list
 
#To determine whether a file is empty
if [ -s ${filepath}/tmpdatabases.list ];then
    #开始时间
    started_time=`date "+%Y-%m-%d %H:%M:%S"`
    echo "备份开始时间:${started_time}"
    db_num00=`awk 'NR==1,NR==0 { print NR}' ${filepath}/tmpdatabases.list |tail -n1`
    echo "此次将备份${db_num00}个数据库:"
    echo
 
    or_dbnum=0
          for i in  `awk 'NR==1,NR==0 { print $1}'  ${filepath}/tmpdatabases.list`;
          do    
            ((or_dbnum+=1))
            mysql_databases=$i
            db_dpname=$dir_backup/${i}.${now_date}
              echo -e "\e[1;32m  mydumper开始备份第${or_dbnum}个数据库$i..... \e[0m"
                sleep 2
                echo -e "\e[1;32m  mydumper玩命备份中.....稍等片刻.... \e[0m"
                ${mydumper} \
                --database=${mysql_databases} \
                --host=${mysql_host} \
                --port=${mysql_port} \
                --user=${mysql_user} \
                --password=${mysql_pass} \
                --outputdir=${db_dpname} \
                --rows=50000 \
                --build-empty-files \
                --threads=4 \
                --compress-protocol \
				--triggers \
				--events  \
				--routines \
                --kill-long-queries 
                if [ "$?" -eq 0 ];then
                echo -e "\e[1;32m  mydumper成功将数据库$i备份到:${db_dpname}. \e[0m"
                echo 
                else
                echo -e "\e[1;31m 备份异常结束. \e[0m"
                fi
          done
else
          dbname='a'
#        dbname=''
#        read -p "Please input you want to backup database name[a|A:ALL]:" dbname
 
        #开始循环
          
        #开始时间
       started_time=`date "+%Y-%m-%d %H:%M:%S"`
        echo "备份开始时间:${started_time}"
        if [ "$dbname" = "a" -o "$dbname" = "A" ];then
         db_num=`awk 'NR==2,NR==0 { print NR-1}' ${fgedudate_01} |tail -n1`
         echo "此次将备份${db_num}个数据库:"
         echo 
         mysql_databases=$dbname
         or_dbnum=0
          for i in  `awk 'NR==2,NR==0 { print $1}'  ${fgedudate_01}`;
          do    
             ((or_dbnum+=1))
            mysql_databases=$i
            db_dpname=$dir_backup/${i}.${now_date}
              echo -e "\e[1;32m  mydumper开始备份第${or_dbnum}个数据库$i..... \e[0m"
                sleep 2
                echo -e "\e[1;32m  mydumper玩命备份中.....稍等片刻.... \e[0m"
                ${mydumper} \
                --database=${mysql_databases} \
                --host=${mysql_host} \
                --port=${mysql_port} \
                --user=${mysql_user} \
                --password=${mysql_pass} \
                --outputdir=${db_dpname} \
                --rows=50000 \
                --build-empty-files \
                --threads=4 \
                --compress-protocol \
				--triggers \
				--events  \
				--routines \
                --kill-long-queries 
                if [ "$?" -eq 0 ];then
                echo -e "\e[1;32m  mydumper成功将数据库$i备份到:${db_dpname}. \e[0m"
                echo 
                else
                echo -e "\e[1;31m 备份异常结束. \e[0m"
                fi
          done
        else 
            echo "此次备份的数据库名为:$dbname"
            echo  
            #开始时间
			started_time=`date "+%Y-%m-%d %H:%M:%S"`
			
            mysql_databases=$dbname
            db_dpname=$dir_backup/${mysql_databases}.${now_date}
 
            fgedudate_02="fgedudate02.`date +%y%m%d%h%m%s`.txt"
            schema_fgedu02="select schema_name from information_schema.schemata where schema_name='${dbname}';"
            $mysqlbin -h${mysql_host} -P${mysql_port}  -u${mysql_user} -p${mysql_pass} -e"${schema_fgedu02}" >${fgedudate_02}
 
            if [ ! -s "${fgedudate_02}" ];then
                echo "                                                                           "
                 
                echo -e "\e[1;31m  ******************************************************************* \e[0m"
                echo -e "\e[1;31m  !o(︶︿︶)o! The  schema_name ${dbname} not exits,pleae check . ~~~~(>_<)~~~~  \e[0m"
                echo -e "\e[1;31m  ********************************************************************** \e[0m"

                echo "                                                                           "
                rm -rf ${fgedudate_01}
                rm -rf ${fgedudate_02}
                exit 0
            else
                echo -e "\e[1;32m  mydumper开始备份请稍等..... \e[0m"
                sleep 2
                echo -e "\e[1;32m  mydumper玩命备份中.....稍等片刻.... \e[0m"
                ${mydumper} \
                --database=${mysql_databases} \
                --host=${mysql_host} \
                --port=${mysql_port} \
                --user=${mysql_user} \
                --password=${mysql_pass} \
                --outputdir=${db_dpname} \
                --rows=50000 \
                --build-empty-files \
                --threads=4 \
                --compress-protocol \
				--triggers \
				--events  \
				--routines \
                --kill-long-queries 
                if [ "$?" -eq 0 ];then
                echo -e "\e[1;32m  mydumper成功将数据库备份到:${db_dpname}. \e[0m"
                else
                echo -e "\e[1;31m 备份异常结束. \e[0m"
                fi             
            fi
 
        # 循环结束
        fi
fi
mysql_exp_grants()
{  
  $mysqlbin -B -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}   $@ -e "SELECT CONCAT(  'SHOW CREATE USER   ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  $mysqlbin -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}  -f  $@ | \
  sed 's#$#;#g;s/^\(CREATE USER for .*\)/-- \1 /;/--/{x;p;x;}' 
 
  $mysqlbin -B -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}   $@ -e "SELECT CONCAT(  'SHOW GRANTS FOR ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  $mysqlbin -u${mysql_user} -p${mysql_pass} -N -P${mysql_port}  -f  $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'   
}  
mysql_exp_grants > $dir_backup/mysql_exp_grants_$dir_date.sql
 
rm -rf ${fgedudate_01}
rm -rf ${fgedudate_02}
rm -rf ${filepath}/tmpdatabases.list
alias cp='cp -f'
cp $dirbackup/$OutLogFile $dir_backup/
tar -zcvPf $dir_backup.tar.gz $dir_backup $MyCNF
find $dirbackup -mtime +3 -name "fullbackup20*" -exec rm -rf {} \;
find $dirbackup -mtime +15 -name "fullbackup20*.gz" -exec rm -rf {} \;

echo "--------------------------------------------------------"
echo "     备份任务完成于: `date +%F' '%T' '%w`" 
echo "--------------------------------------------------------"