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