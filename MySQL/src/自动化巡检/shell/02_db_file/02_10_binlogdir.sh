mysql -uroot -N -e "Show variables like 'log_bin_basename';"|grep -v "^-"|awk -F " " '{print $2}'
