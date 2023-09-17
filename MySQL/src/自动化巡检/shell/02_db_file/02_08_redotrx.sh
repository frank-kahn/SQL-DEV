mysql -uroot -N -e "show variables like 'innodb_flush_log_at_trx_commit';"|grep -v '^-'|awk -F " " '{print $2}'
