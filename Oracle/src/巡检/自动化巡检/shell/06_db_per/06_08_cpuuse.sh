#echo "###CPU前10名###"
#ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head -10
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head -10|awk -F' ' '{print $1,$4,$11}'
