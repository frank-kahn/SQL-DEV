mysql -uroot -N -e "Show variables like 'log_bin';"|grep -v '^-'|awk -F " " '{print $2}'
