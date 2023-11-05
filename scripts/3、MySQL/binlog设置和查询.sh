cat >> /mysql/data/3306/my.cnf << EOF
[mysqld]
log_bin=/mysql/log/3306/binlog/testdb-binlog
log_bin_index=/mysql/log/3306/binlog/testdb-binlog.index
binlog_format='row'
binlog_rows_query_log_events=on
EOF

#创建目录并授权：
mkdir -p /mysql/log/3306/binlog
chown -R mysql:mysql /mysql/log/3306/binlog
chmod -R 755 /mysql/log/3306/binlog

#重启MySQL服务
service mysql restart


show variables like 'expire_logs_days';

show binlog events in 'itpuxdb-binlog.000003';
show binary logs;
