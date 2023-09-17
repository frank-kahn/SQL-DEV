ps -ef|grep mysqld|grep -v grep|awk -F " " '{print $9}'|awk -F "=" '{print $2}'
