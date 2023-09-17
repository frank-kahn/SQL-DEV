lsnrctl status|grep "PORT="|grep -v "Conn"|awk -F "=" '{print $6}'|sed 's/)//g'
