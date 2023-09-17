mysql -uroot -N -e "Show variables like 'relay_log_info_file';"|grep -v "^-"|awk -F " " '{print $2}'
