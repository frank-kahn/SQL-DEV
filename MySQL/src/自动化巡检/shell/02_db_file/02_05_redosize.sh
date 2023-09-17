mysql -uroot -N -e "show variables like 'innodb_log_file_size';"|grep -v '^-'|awk -F " " '{print $2}'
