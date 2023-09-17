mysql -uroot -N -e "SHOW SLAVE STATUS\G;"|grep -w Slave_SQL_Running|awk -F":"  '{print $2}'
