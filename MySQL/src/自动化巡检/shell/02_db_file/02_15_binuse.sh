mysql -uroot -N -e "Show variables like '%binlog_cache%';"|grep -v "^-"
