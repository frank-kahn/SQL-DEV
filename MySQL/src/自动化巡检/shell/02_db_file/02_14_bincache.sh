mysql -uroot -N -e "Show variables like 'binlog_cache_size';"|grep -v "^-"|awk -F " " '{print $2}'
