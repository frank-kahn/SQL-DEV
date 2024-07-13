#!/bin/bash

#######################################
#
#     Version 1.0
#     Author:Robin Han
#     Date:2015/06/06
#     It will do rman backup
#     usage:rman_ohsdba.sh <0,1,2,3>
#     http://ohsdba.cn
#
########################################
. /home/oracle/.base_profile

export DBNAME=pgold
export LOGPATH=/pgold/ordb/oracle/product/admin/log
export COMPRESS=compressed
export CATALOG=
export FRA=1

if [ $FRA -ne 1 ];then
    export DB_F="format '/pgold/hot/db_%U'"
    export ARCH_F="format '/pgold/hot/arch_%U'"
fi


function do_rman_level0 {
rman target / $CATALOG log=$LOGPATH/${DBNAME}_level0_$(date +"%Y%m%d%H%M").log <<EOF
sql "alter session set nls_date_format=''yyyy-mm-dd hh24:mi:ss''";

run{
backup  incremental level 0 tag "incr_L0" as $COMPRESS backupset database $DB_F filesperset 16;
}
EOF

}


function do_rman_level1 {
rman target / $CATALOG log=$LOGPATH/${DBNAME}_level1_$(date +"%Y%m%d%H%M").log <<EOF
sql "alter session set nls_date_format=''yyyy-mm-dd hh24:mi:ss''";

run {
backup incremental level 1 tag "incr_L1" as $COMPRESS backupset database $DB_F filesperset 16;
}
EOF
}

function do_rman_arch {
rman target / $CATALOG log=$LOGPATH/${DBNAME}_arch_$(date +"%Y%m%d%H%M").log <<EOF
sql "alter session set nls_date_format=''yyyy-mm-dd hh24:mi:ss''";
sql 'alter system archive log current';
RUN
{
backup  tag "arch" AS $COMPRESS backupset archivelog all $ARCH_F not backed up 1 times;
}
sql 'alter system archive log current';
EOF
}

function do_rman_clear {
rman target / $CATALOG log=$LOGPATH/${DBNAME}_obsolete_$(date +"%Y%m%d%H%M").log <<EOF
sql "alter session set nls_date_format=''yyyy-mm-dd hh24:mi:ss''";
RUN
{
crosscheck backup;
crosscheck archivelog all;
report obsolete recovery window of 15 days device type disk;
delete noprompt obsolete recovery window of 15 days device type disk;
delete noprompt archivelog all completed before 'sysdate-15' device type disk;
delete noprompt expired backup;
}
sql 'alter database backup controlfile to trace';
EOF
}


function do_help {
echo -e "\n"
echo -e "\t rman_ohsdba.sh 0 will do level 0 backup"
echo -e "\t rman_ohsdba.sh 1 will do level 1 backup"
echo -e "\t rman_ohsdba.sh 2 will do archivelog backup"
echo -e "\t rman_ohsdba.sh 3 will clear expired and obsolete backup"
echo -e "\t If any questions,please check with Wechat ohsdba"
echo -e "\n"
}

if [ x$1 = x ]; then
   do_help
   exit
else
   expr $1 + 1 &>/dev/null
   [ $? -ne 0 ] && { echo -e "\tArgs must be integer!";exit 1; }
fi


case $1 in
    0)
        do_rman_level0
        ;;
    1)
        do_rman_level1
        ;;
    2)
        do_rman_arch
        ;;
    3)
        do_rman_clear
        ;;
    *)
        do_help
        ;;
esac
exit 0