mysql -uroot -N -e "Show master status\G;"|grep -v "*"|head -n 2
