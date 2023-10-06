-- MySQL 主从从结构logs-slave-updates选项
Mysql默认从库是不会将同步的LOG写入BINLOG的，如果即要做从又要做主的主从从结构，需要在从库的配置文件中添加以下开关选项：
log_slave_updates

