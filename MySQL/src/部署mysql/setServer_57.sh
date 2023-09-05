#!/bin/bash

#目录、端口、实例名等信息的配置文件
INI_CFG=./setServer.ini

#IP
IP=""

#软件目录
SOFTDIR=""

#根目录
BASE_DIR=""

#实例名
INS_NAME=""

#实例名前缀
INS_NAME_PRE=""

#实例端口
INS_PORT=""

#server id
SERVER_ID=""

#实例根目录
INS_BASE_DIR=""

#管理员用户
ADMIN_USER=""

#管理员密码
ADMIN_PASSWD=""

#实例参数文件
INS_CNF=""

#初始化SQL文件
INIT_FILE=""

#INNODB_BUFFER_POOL_SIZE设定
BUFFER_POOL=""

function Isok()
{
[ $? == "0" ] && echo "Complete OK !" || echo " Failed !!!";exit 128
}

#创建实例函数
function create_instance()
{

#1、创建实例相应目录 
mkdir -p ${INS_BASE_DIR}/{bin,conf,data,rlog,ulog,blog,elog,tmp}
chmod -R 750 ${INS_BASE_DIR}
 
echo "****** 1、创建目录："
echo "  启动脚本目录：${INS_BASE_DIR}/bin"
echo "  配置文件目录：${INS_BASE_DIR}/conf"
echo "  数据目录：${INS_BASE_DIR}/data"
echo "  relog目录：${INS_BASE_DIR}/rlog"
echo "  ulog目录：${INS_BASE_DIR}/ulog"
echo "  blog目录：${INS_BASE_DIR}/blog"
echo "  elog目录：${INS_BASE_DIR}/elog"
echo "  临时目录：${INS_BASE_DIR}/tmp"
 
 
#2、生成参数文件
cat <<EOF >${INIT_FILE}
set global sql_safe_updates=0;
EOF

cat <<EOF >${INS_CNF} 
[mysqld]
#************** basic ***************
datadir                         =${INS_BASE_DIR}/data
basedir                         =${SOFTDIR}
tmpdir                          =${INS_BASE_DIR}/tmp
secure_file_priv                =${INS_BASE_DIR}/tmp
port                            =${INS_PORT}
socket                          =${INS_BASE_DIR}/mysql.sock
pid_file                        =${INS_BASE_DIR}/mysql.pid

#************** connection ***************
max_connections                 =5000
max_connect_errors              =100000
max_user_connections            =1200

#************** sql timeout & limits ***************
max_execution_time              =10000
group_concat_max_len            =1048576
lock_wait_timeout               =60
#autocommit                      =0
lower_case_table_names          =1
thread_cache_size               =64
disabled_storage_engines        ="MyISAM,FEDERATED"
character_set_server            =utf8mb4
transaction-isolation           ="READ-COMMITTED"
skip_name_resolve               =ON
explicit_defaults_for_timestamp =ON
log_timestamps                  =SYSTEM
local_infile                    =OFF
event_scheduler                 =OFF
query_cache_type                =OFF
query_cache_size                =0
lc_messages                     =en_US
lc_messages_dir                 =${SOFTDIR}/share
init_connect                    ="set names utf8mb4"
#sql_mode                        =NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO
init_file                       =${INIT_FILE}
#init_slave
performance_schema_max_table_instances  =1000

#******************* err & slow & general ***************
log_error                       =${INS_BASE_DIR}/elog/mysql.err
#log_output                      ="TABLE,FILE"
slow_query_log                  =ON
slow_query_log_file             =${INS_BASE_DIR}/elog/slow.log
long_query_time                 =1
log_queries_not_using_indexes   =0
log_throttle_queries_not_using_indexes = 10
general_log                     =OFF
general_log_file                =${INS_BASE_DIR}/elog/general.log

#************** binlog & relaylog ***************
expire_logs_days                =7
sync_binlog                     =1
log-bin                         =${INS_BASE_DIR}/blog/mysql-bin
log-bin-index                   =${INS_BASE_DIR}/blog/mysql-bin.index
max_binlog_size                 =500M
binlog_format                   =ROW
binlog_rows_query_log_events    =ON
binlog_cache_size               =2M
binlog_stmt_cache_size          =2M
max_binlog_cache_size           =512M
max_binlog_stmt_cache_size      =512M

relay_log                       =${INS_BASE_DIR}/blog/relay
relay_log_index                 =${INS_BASE_DIR}/blog/relay.index
max_relay_log_size              =500M
relay_log_purge                 =ON
relay_log_recovery              =ON

#*************** rpl_semi_sync ***************
#loose_rpl_semi_sync_master_enabled                =ON
#loose_rpl_semi_sync_master_timeout                =1000
#loose_rpl_semi_sync_master_trace_level            =32
#loose_rpl_semi_sync_master_wait_for_slave_count   =1
#loose_rpl_semi_sync_master_wait_no_slave          =ON
#loose_rpl_semi_sync_master_wait_point             =AFTER_SYNC
#loose_rpl_semi_sync_slave_enabled                 =ON
#loose_rpl_semi_sync_slave_trace_level             =32

#*************** group commit ***************
binlog_group_commit_sync_delay              =1
binlog_group_commit_sync_no_delay_count     =1000

#*************** gtid ***************
gtid_mode                       =ON
enforce_gtid_consistency        =ON
master_verify_checksum          =ON
sync_master_info                =1

#*************slave ***************
skip-slave-start                =1
#read_only                      =ON
#super_read_only                =ON
log_slave_updates               =ON
server_id                       =${SERVER_ID}
report_host                     =$IP
report_port                     =${INS_PORT}
slave_load_tmpdir               =${INS_BASE_DIR}/tmp
slave_sql_verify_checksum       =ON
slave_preserve_commit_order     =1

#*************** muti thread slave ***************
slave_parallel_type                         =LOGICAL_CLOCK
slave_parallel_workers                      =4
master_info_repository                      =TABLE
relay_log_info_repository                   =TABLE

#*************** buffer & timeout ***************
read_buffer_size                =1M
read_rnd_buffer_size            =2M
sort_buffer_size                =1M
join_buffer_size                =1M
tmp_table_size                  =16777216
max_allowed_packet              =64M
max_heap_table_size             =64M
connect_timeout                 =10
wait_timeout                    =600
interactive_timeout             =600
net_read_timeout                =30
net_write_timeout               =30

#*********** myisam ***************
skip_external_locking           =ON
key_buffer_size                 =2M
bulk_insert_buffer_size         =16M
concurrent_insert               =ALWAYS
open_files_limit                =65000
table_open_cache                =1000
table_definition_cache          =400

#*********** innodb ***************
default_storage_engine              =InnoDB
default_tmp_storage_engine          =InnoDB
internal_tmp_disk_storage_engine    =InnoDB
innodb_data_home_dir                =${INS_BASE_DIR}/data
innodb_log_group_home_dir           =${INS_BASE_DIR}/rlog
innodb_log_file_size                =1024M
innodb_log_files_in_group           =3
innodb_undo_directory               =${INS_BASE_DIR}/ulog
innodb_undo_log_truncate            =on  
innodb_max_undo_log_size            =1024M
innodb_undo_tablespaces             =3
innodb_flush_log_at_trx_commit      =2
innodb_fast_shutdown                =1
innodb_flush_method                 =O_DIRECT
innodb_io_capacity                  =1000
innodb_io_capacity_max              =4000
innodb_buffer_pool_size             =${BUFFER_POOL}
innodb_log_buffer_size              =8M
innodb_autoinc_lock_mode            =1
innodb_buffer_pool_load_at_startup  =ON
innodb_buffer_pool_dump_at_shutdown =ON
innodb_buffer_pool_dump_pct         =15
innodb_max_dirty_pages_pct          =85
innodb_lock_wait_timeout            =10
#innodb_locks_unsafe_for_binlog      =1
innodb_old_blocks_time              =1000
innodb_open_files                   =63000
innodb_page_cleaners                =4
innodb_strict_mode                  =ON
innodb_thread_concurrency           =0
innodb_sort_buffer_size             =1M
innodb_print_all_deadlocks          =1
innodb_rollback_on_timeout          =ON
EOF

 
echo "****** 2、生成参数文件："
echo "  实例${INS_NAME}的参数文件: ${INS_CNF}"
 
# 3、实例化数据库
echo "****** 3、初始化数据库："
[ `echo $USER` == "root" ] && chown -R mysql:mysql ${INS_BASE_DIR}
${SOFTDIR}/bin/mysqld --defaults-file=${INS_CNF} \
--initialize-insecure --user=mysql \
--basedir=${SOFTDIR} \
--datadir=${INS_BASE_DIR}/data

#4、生成启动、关闭、登陆脚本
echo "****** 4、生成启动、关闭、登陆脚本："
 
cat <<EOF >${INS_BASE_DIR}/bin/startup.sh
#!/bin/bash
source /etc/profile
source ~/.bash_profile
export UMASK=0644
export UMASK_DIR=0750
## vars
SOFTDIR=${SOFTDIR}
DBHOME=${INS_BASE_DIR}
DBNAME=${INS_NAME}
CNF=\${DBHOME}/conf/\${DBNAME}.cnf
DATADIR=\${DBHOME}/data
## startup
nohup \${SOFTDIR}/bin/mysqld_safe --defaults-file=\${CNF} --ledir=\${SOFTDIR}/bin >\${DBHOME}/nohup.out 2>&1 &
EOF


cat <<EOF >${INS_BASE_DIR}/bin/shutdown.sh
#!/bin/bash
source /etc/profile
source ~/.bash_profile
## vars
SOFTDIR=${SOFTDIR}
DBHOME=${INS_BASE_DIR}
DBNAME=${INS_NAME}
CNF=\${DBHOME}/conf/\${DBNAME}.cnf
SOCK=\${DBHOME}/mysql.sock
## shutdown
\${SOFTDIR}/bin/mysqladmin --defaults-file=\${CNF} -uroot -p -S\${SOCK} shutdown
EOF


cat <<EOF >${INS_BASE_DIR}/bin/login.sh
SOFTDIR=${SOFTDIR}
DBHOME=${INS_BASE_DIR}
DBNAME=${INS_NAME}
SOCK=\${DBHOME}/mysql.sock
\${SOFTDIR}/bin/mysql -uroot -p -S\${SOCK} -A
EOF

chmod 700 ${INS_BASE_DIR}/bin/startup.sh ${INS_BASE_DIR}/bin/shutdown.sh ${INS_BASE_DIR}/bin/login.sh

#5、修改管理员密码
echo "****** 5、修改管理员密码："
hostname=`hostname`


sh ${INS_BASE_DIR}/bin/startup.sh
sleep 30

${SOFTDIR}/bin/mysql -uroot -S${INS_BASE_DIR}/mysql.sock<<EOF
#install semi sync
install plugin rpl_semi_sync_slave soname 'semisync_slave.so';
install plugin rpl_semi_sync_master soname 'semisync_master.so';
#root
alter user 'root'@'localhost' identified by "${ADMIN_PASSWD}";
delete from mysql.user where user='root' and host=lower("${hostname}");
#备份用户
GRANT SELECT,SHOW VIEW,TRIGGER,LOCK TABLES,RELOAD,PROCESS,SUPER ON *.* TO 'bkpuser'@'%' IDENTIFIED BY "n#CJ^f&i";    
#复制用户
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replic'@'%' IDENTIFIED BY "4%REplic";
#inception用户
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, PROCESS, INDEX, ALTER, SUPER, REPLICATION SLAVE, REPLICATION CLIENT, TRIGGER ON *.* TO inception identified by 'fF&w@tw5qZK1WRvi';
flush privileges;
shutdown;
EOF
[ $? == "0" ] && echo " 密码修改成功!"

#修改配置文件，使半同步参数生效
sleep 5
sed -i 's/loose_//g' ${INS_CNF}
sh ${INS_BASE_DIR}/bin/startup.sh

echo "****** 6、网络监听:"
netstat -pltn 2>/dev/null |grep -E "Proto|$INS_PORT|mysql"

echo "****** 7、MySQL错误日志:"
grep -Ei "error|warning" $INS_BASE_DIR/elog/mysql.err
}


if [ -f ${INI_CFG} ]; then

 grep -v "^#" ${INI_CFG} | while read line

 do
   
          IP=`echo ${line} | cut -d" " -f1`
          SOFTDIR=`echo ${line} | cut -d" " -f2 | sed 's/\/$//'`
          BASE_DIR=`echo ${line} | cut -d" " -f3 | sed 's/\/$//'`
          INS_NAME_PRE=`echo ${line} | cut -d" " -f4`
          INS_NAME=`echo ${line} | cut -d" " -f5`
          INS_PORT=`echo ${line} | cut -d" " -f6`
          SERVER_ID=`echo ${line} | cut -d" " -f7`
          ADMIN_USER=`echo ${line} | cut -d" " -f8`
          ADMIN_PASSWD=`echo ${line} | cut -d" " -f9`
          BUFFER_POOL=`echo ${line} | cut -d" " -f10`
          INS_BASE_DIR=${BASE_DIR}/${INS_NAME_PRE}_${INS_NAME}
          INS_CNF=${INS_BASE_DIR}/conf/${INS_NAME}.cnf
	  INIT_FILE=${INS_BASE_DIR}/conf/init_file.sql
         
          echo "****** 实例${INS_NAME}信息: ******"
          echo "        IP: ${IP}"
          echo "        软件目录: ${SOFTDIR}"
          echo "        根目录: ${BASE_DIR}"
          echo "        实例根目录: ${INS_BASE_DIR}"
          echo "        实例名前缀: ${INS_NAME_PRE}"
          echo "        实例名: ${INS_NAME}"
          echo "        实例端口: ${INS_PORT}"
          echo "        server_id: ${SERVER_ID}"
          echo "        管理员用户: ${ADMIN_USER}"
          echo "        管理员密码: ${ADMIN_PASSWD}"
	  echo "        INNODB_BUFFER_POOL_SIZE设定: ${BUFFER_POOL}"
         
          if [ `echo ${line} | awk '{print NF}'` != "10" ]; then
         
          echo "ERROR：创建实例相应参数不够！"
          echo "##############################################################################################"
          echo -e "\n"
         
          #判断端口与ibdata01文件是否存在，都不存在则创建实例。存在一个则创建失败
          elif [ X"`netstat -ltn | grep ${INS_PORT}`" = X"" ] && [ ! -f ${INS_BASE_DIR}/data/ibdata01 ]; then
    
          #调用创建实例函数
          create_instance;

       else
        
         echo "ERROR：端口${INS_PORT}或${INS_BASE_DIR}/data/ibdata01文件存在，创建实例失败！"
         echo "##############################################################################################"
                   echo -e "\n"
         
   fi
         
done
  
else

 echo "ERROR：${INI_CFG}配置文件不存在！"
 exit 1

fi

