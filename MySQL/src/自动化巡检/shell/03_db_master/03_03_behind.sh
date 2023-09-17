mysql -uroot -N -e "SHOW SLAVE STATUS\G;"|grep -w Seconds_Behind_Master|awk -F":"  '{print $2}'
