errlog=`mysql -uroot -N -e "show variables like 'log_error';"|grep -v "^-"|awk -F " " '{print $2}'`
tail -n 100 $errlog|grep -i error
