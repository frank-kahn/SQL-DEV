mysql -uroot -N -e "show variables like 'innodb_log_group_home_dir';"|grep -v '^-'|awk -F " " '{print $2}'
