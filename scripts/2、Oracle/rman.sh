#待研究
https://blog.csdn.net/leshami/article/details/9011789


#####################################配置catalog#####################################
mkdir /oradata/testdb -p
chown -R oracle:oinstall /oradata

#1、sqlplus创建用户和表空间
create tablespace rman_tbs datafile '/oradata/testdb/rman.dbf' size 50m autoextend off;
create user rman identified by rman default tablespace rman_tbs;
grant connect,resource,recovery_catalog_owner to rman;
alter user rman quota unlimited on rman_tbs;
#2、创建恢复目录
rman catalog rman/rman
RMAN> create catalog tablespace rman_tbs;
#3、配置目标数据库的tnsnames.ora
cat >> $ORACLE_HOME/network/admin/tnsnames.ora << "EOF"
rman =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = testos)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = testdb)
    )
  )
EOF
#4、注册目标数据库
rman target / catalog rman/rman@rman
RMAN> register database;


#使用catalog 连接
rman target sys/oracle catalog rman/rman@testdb


#使用 nocatlog 连接
rman target sys/oracle nocatalog
rman target sys/oracle
rman target /

################################### rman 0级和1级备份 ##################################
#环境准备
#数据库启动归档
mkdir /rman/{db,arch} -p
chown oracle.oinstall /rman -R
su - oracle
sqlplus / as sysdba
SQL> alter system set log_archive_dest_1='location=/rman/arch';
SQL> alter system set log_archive_format = "testdb_%t_%s_%r.arc" scope=spfile;
SQL> shutdown immediate;
SQL> startup mount;
SQL> alter database archivelog;
SQL> alter database open;
SQL> archive log list;
#创建测试数据
SQL> conn hr/hr
SQL> create table t1 as select level as id from dual connect by level <=10;
#0级备份脚本
cat 0_rmanbak.sh
export NLS_DATA_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman target / log=/rman/db/0_rmanbak.log << "EOF"
run{
allocate channel ch1 type disk maxpiecesize 1000M;
allocate channel ch2 type disk maxpiecesize 1000M;
backup incremental level = 0
filesperset = 32
format '/rman/db/lev0_%d_%T_%U.bak'
skip inaccessible database
include current controlfile
tag '0_rmanbak_testdb';
release channel ch1;
release channel ch2;
}
EOF
exit

#1级备份脚本
cat 1_rmanbak.sh
export NLS_DATA_FORMAT='yyyy-mm-dd hh24:mi:ss'
rman target / log=/rman/db/1_rmanbak.log << "EOF"
run{
allocate channel ch1 type disk maxpiecesize 1000M;
allocate channel ch2 type disk maxpiecesize 1000M;
backup incremental level = 1
filesperset = 32
format '/rman/db/lev1_%d_%T_%U.bak'
skip inaccessible database
include current controlfile
tag '1_rmanbak_testdb';
release channel ch1;
release channel ch2;
}
EOF
exit


#执行0级备份
sh 0_rmanbak.sh
#执行1级备份
sh 1_rmanbak.sh




#rman 并行参数
https://blog.csdn.net/dzjun/article/details/50454374
https://blog.csdn.net/hezuijiudexiaobai/article/details/118617060
https://zhuanlan.zhihu.com/p/71514667



#Oracle rman工具使用（真的细）
https://blog.csdn.net/tttzzzqqq2018/article/details/132939674

#RMAN异机恢复与复制数据库(归档和非归档模式区别，RMAN使用实例)
https://www.cnblogs.com/muhai/p/15829986.html


# 压缩备份
https://blog.csdn.net/lihuarongaini/article/details/101299256


# 全备的同时压缩备份
#1、使用as compressed backupset子句
backup as compressed backupset full database format ='D:\oracle\backup\dbprifull_%U';
backup as compressed backupset full database format '/u01/app/oracle/rmanbak/full_bk1_%u%p%s.rmn';

#2、使用 configure命令设置
configure device type disk parallelism 2 backup type to compressed backupset;
backup full database format ='d:\oracle\backup\dbprifull_%u';
configure device type disk backup type to backupset;


#使用RMAN传输数据_复制数据库
https://blog.csdn.net/jetliu05/article/details/122701850


################################### 全备数据库 ##################################
mkdir -p /oracle/backup

#全备主库
rman target /

run {
configure device type disk parallelism 2 backup type to compressed backupset;
backup full database format ='/oracle/backup/db_backfull_%u';
configure device type disk backup type to backupset;
}


#############################  全备和恢复 #######################################
#全备
sys@testdb(testos)> select min(checkpoint_change#) from v$datafile_header;
MIN(CHECKPOINT_CHANGE#)
-----------------------
                 989878
#整理rman cmdfile文件
cat > rman_cmdfile << "EOF"
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to '/oracle/backup/autobak_CF_%F';
run {
allocate channel c1 type disk format '/oracle/backup/fullbak_%U' maxpiecesize 32g;
allocate channel c2 type disk format '/oracle/backup/fullbak_%U' maxpiecesize 32g;
allocate channel c3 type disk format '/oracle/backup/fullbak_%U' maxpiecesize 32g;
allocate channel c4 type disk format '/oracle/backup/fullbak_%U' maxpiecesize 32g;
backup current controlfile format '/oracle/backup/temp_01_control.bak';
backup as compressed backupset full database;
backup current controlfile format '/oracle/backup/use_this_control.bak';
backup as compressed backupset archivelog from scn=989878 skip inaccessible;
backup current controlfile format '/oracle/backup/temp_02_control.bak';
}
configure controlfile autobackup off;
exit
EOF
#创建备份存放目录
mkdir -p /oracle/backup
#执行全备
rman target / cmdfile rman_cmdfile msglog backup.log

#恢复
rman target /

run {
set until scn 989878;
restore database;
recover database;
}




#全备
backup tag testdb_full format '/backup/full/full_testdb_%s_%p_%t' (database);
