mysql -uroot -N -e "Show variables like 'binlog_format';"|grep -v "^-"|awk -F " " '{print $2}'
