#!/bin/bash
# Last updated: 2022-05-27
# ---------------------------------------------------------------------------------------------------#
# Copyright (C) 2022-05-27 yuanzijian                                                                #
# Email : yzj@dameng.com                                                                             #
# Web : http://eco.dameng.com                                                                        #
#执行脚本前：                                                                                        #
#     1. 把脚本放入Oracle家目录，例如：/home/oracle/rmanbak.sh                                       #
#     2. 修改属组和权限：                                                                            #
#            chown -R oracle.oinstall /home/oracle/rmanbak.sh                                        #
#            chmod -R 775 /home/oracle/rmanbak.sh                                                    #
#     3. 添加定时任务,每天两点执行备份脚本                                                           #
#            echo "00 02 * * * /home/oracle/rmanbak.sh >/dev/null 2>&1 &" >>/var/spool/cron/oracle   #
#     4. 设置好主机IP"                                                                               #
# ---------------------------------------------------------------------------------------------------#
if [ -f $HOME/.bash_profile ]; then
    . $HOME/.bash_profile
elif [ -f $HOME/.profile ]; then
        . $HOME/.profile
fi
##全量备份时间，例如：周六
fulbakdatetime=(6)            

##增量备份时间，例如：周日~周五
incbakdatetime=(0 1 2 3 4 5)      

##冗余策略保留份数
quantity=2

datetime=`date +%w`
backtime=`date +"20%y%m%d%H%M%S"`

##备份目录,请指定到Oracle用户有权限建的目录下，也可以是/orabak
##[oracle@ora21c.yuanzj.com:/home/oracle]$  ls -ld /orabak
##drwxr-x--- 3 oracle oinstall 4096 May 27 19:01 /orabak
###################################################
orabakdir=/orabak
[[ -e ${orabakdir} ]] || mkdir -p ${orabakdir}
chown -R oracle:oinstall ${orabakdir}
chmod -R 750 ${orabakdir}

##备份策略
rmanPolicy(){
 rman target / log=${orabakdir}/rmanbak_${backtime}.log<<EOF
  run{
    CONFIGURE RETENTION POLICY TO REDUNDANCY ${quantity};
    CONFIGURE CONTROLFILE AUTOBACKUP ON;
  }
EOF
}

#全量备份
fulBak(){
 rman target / log=${orabakdir}/level0_backup_${backtime}.log<<EOF
  sql 'alter session set nls_date_format="yyyy-mm-dd hh24:mi:ss"';
  run {
   allocate channel c1 device type disk;
   allocate channel c2 device type disk;
   crosscheck backup;
   crosscheck archivelog all; 
   sql"alter system archive log current";
   delete noprompt expired backup;
   delete noprompt obsolete device type disk;
   backup incremental level 0 database include current controlfile format '${orabakdir}/backlv0_%d_%T_%t_%s_%p' plus archivelog  delete all input format '${orabakdir}/arch_%d_%T_%t_%s_%p';
   backup spfile format='${orabakdir}/spfile_%d_%T_%t_%s_%p';
   release channel c1;
   release channel c2;
  }
EOF
}

#增量备份
incBak(){
 rman target / log=${orabakdir}/level1_backup_${backtime}.log<<EOF
  sql 'alter session set nls_date_format="yyyy-mm-dd hh24:mi:ss"';
  run {
   allocate channel c1 device type disk;
   allocate channel c2 device type disk;
   crosscheck backup;
   crosscheck archivelog all; 
   sql"alter system archive log current";
   delete noprompt expired backup;
   delete noprompt obsolete device type disk;
   backup incremental level 1 database include current controlfile format '${orabakdir}/backlv1_%d_%T_%t_%s_%p' plus archivelog  delete all input format '${orabakdir}/arch_%d_%T_%t_%s_%p';
   release channel c1;
   release channel c2;
  }
EOF
}

for dbbaktime1 in ${fulbakdatetime[@]}
do
    if [[ ${dbbaktime1} == ${datetime} ]];then
	 rmanPolicy
	 fulBak
	 break
	fi
done

for dbbaktime2 in ${incbakdatetime[@]}
do
    if [[ ${dbbaktime2} == ${datetime} ]];then
	 incBak
	 break
	fi
done

