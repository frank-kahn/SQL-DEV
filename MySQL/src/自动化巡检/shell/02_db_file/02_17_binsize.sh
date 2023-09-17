mysql -uroot -N -e "Show variables like 'Max_binlog_size';"|grep -v "^-"|awk -F " " '{print $2}'
