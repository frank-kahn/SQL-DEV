mysql -uroot -N -e "show variables like 'innodb_log_files_in_group';"|grep -v '^-'|awk -F " " '{print $2}'
