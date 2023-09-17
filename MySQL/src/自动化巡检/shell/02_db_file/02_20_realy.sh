mysql -uroot -N -e "Show variables like 'relay_log_info_repository';"|grep -v "^-"|awk -F " " '{print $2}'
