mysql -uroot -N -e "show variables like 'innodb_log_buffer_size';"|grep -v '^-'|awk -F " " '{print $2}'
