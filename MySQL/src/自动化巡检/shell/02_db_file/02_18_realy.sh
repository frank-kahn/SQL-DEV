mysql -uroot -N -e "Show variables like 'relay_log_basename';"|grep -v "^-"|awk -F " " '{print $2}'
