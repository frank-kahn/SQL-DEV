mysql -uroot -N -e "show variables like 'port';"|grep -v "^-"|awk -F" " '{print $2}'
