#Linux目录权限备份
#将目录权限递归备份至Oracle.txt
getfacl -R /home/Oracle > /tmp/Oracle.txt
#目录权限还原 #通过之前备份的文件还原目录权限
setfacl -R --set-file=/tmp/Oracle.txt /home/Oracle