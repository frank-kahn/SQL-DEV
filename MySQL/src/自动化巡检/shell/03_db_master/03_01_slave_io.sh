mysql -uroot -N -e "SHOW SLAVE STATUS\G;"|grep Slave_IO_Running|awk -F":"  '{print $2}'
