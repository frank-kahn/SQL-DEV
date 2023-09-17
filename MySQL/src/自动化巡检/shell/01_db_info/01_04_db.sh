mysql -uroot -N -e "select distinct db from mysql.db where db not in ('sys','information_schema','performance_schema','mysql');"|grep -v "^-"
