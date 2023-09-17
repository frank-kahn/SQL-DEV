mysqldumpslow -s t -t 1 /mysqldata/13309/mysql/log/slow-query.log|grep -v "N.N.N"|grep -v "^$"|grep -v "Reading" 
