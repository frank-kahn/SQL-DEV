--HA管理
--root下启动ha服务
crsctl start has
--grid用户查看asm磁盘组信息
crs_stat -t


crs_stat -t			#后期版本命令废弃
crs_stat -t -v		#后期版本命令废弃
crsctl stat res -t
crsctl status resource -t

crsctl：对集群组件进行操作
crsctl check crs
crsctl check css
crsctl check ctss
crsctl check cluster -all
crsctl stop/start has	(root下执行，只对当前节点有效，默认随os启动自启动)
crsctl enable/disable has  (设置has开机是否自启动)
crsctl stop/start crs	(root下执行，只对当前节点有效)
crsctl stop cluster -all  (停止多个节点的cluster服务)

srvctl start/stop database -d rac_db
srvctl start/stop instance -d rac_db -i racdb_1
srvctl start instance -d rac_db -i racdb_1 -o nomount|mount
srvctl stop instance -d rac_db -i racdb_1 -o immediate|abort



-- asm磁盘组详细信息

col NAME for a13
col STATE for a7
col TYPE for a6
col PATH for a31
col HEADER_STATUS for a13
col FAILGROUP for a13
col TOTAL_MB for 9999999999
col FREE_MB for 9999999999

select t1.NAME,t1.STATE,t1.TYPE,t2.PATH,t2.HEADER_STATUS,t2.NAME,t2.FAILGROUP,t1.TOTAL_MB,t1.FREE_MB
from v$asm_diskgroup t1
join v$asm_disk t2 using(GROUP_NUMBER);