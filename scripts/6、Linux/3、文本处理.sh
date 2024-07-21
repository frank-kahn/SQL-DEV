#抓报错信息
grep -nE 'error|ERROR|FATAL|' *.log > collect.log


#awk取指定行或列
#1、打印文件的第一列(域)
awk '{print $1}' filename
#2、打印文件的前两列(域)
awk '{print $1,$2}' filename
#3、打印完第一列，然后打印第二列
awk '{print $1 $2}' filename
#4、打印文本文件的总行数
awk 'END{print NR}' filename
#5、打印文本第一行
awk 'NR==1{print}' filename
#6、打印文本第二行第一列
sed -n "2, 1p" filename | awk 'print $1'


#获取某天产生的xlog大小
ll|grep "Jun  3"|awk '{print $5}'|echo $[ $(tr '\n' '+')0]

#两行变一行
sed '{N;s/\n//}' filename

# sed命令
sed -i '/匹配的信息/s///g' regular_express.txt


# 获取终端的ip地址
ip addr show ens33 | awk -F "[ /]+" '/inet /{print $3}'
ifconfig ens33 | awk -F "[ :]+" '/inet /{print $4}'

# IP地址
ifconfig eth0 | grep "inet addr:" | awk -F " " '{print $2}' | awk -F ":" '{print $2}'
# 广播地址
ifconfig eth0 | grep "inet addr:" | awk -F " " '{print $3}' | awk -F ":" '{print $2}'
# 子网掩码
ifconfig eth0 | grep "inet addr:" | awk -F " " '{print $4}' | awk -F ":" '{print $2}'
# 默认网关
route | grep 'default' | awk '{print $2}' 
ip a | grep team0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v 127.0.0.1  | cut -c 6-
ifconfig |grep e[[:alnum:]+]

