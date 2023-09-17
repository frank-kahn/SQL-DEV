mysql -uroot -N -e "\s"|grep -i uptime|awk -F ":" '{print $2}'|grep -v "^$"|sed 's/^[ \t]*//g'
