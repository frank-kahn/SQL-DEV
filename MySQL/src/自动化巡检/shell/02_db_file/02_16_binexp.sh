mysql -uroot -N -e "Show variables like '%expire_logs_days%';"|grep -v "^-"|awk -F " " '{print $2}'
