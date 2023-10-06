sed课程
https://edu.51cto.com/center/course/lesson/index?id=306465

Linux入门学习教程-2019全新正则表达式及vim进阶
https://edu.51cto.com/course/15296.html

马哥教育2016Linux培训教程-awk命令
https://edu.51cto.com/course/5542.html

# shell linux中如何用shell写一个占用CPU的脚本
https://www.jb51.net/article/223724.htm

#Linux 磁盘空间满了，但是实际目录文件占用空间并没有那么大
https://www.cnblogs.com/js1314/p/14179017.html


#系统监控
#查看IO
iostat -k -x 1
#查看网络
sar -n DEV 1
#查看热点函数
perf top
perf record
perf report


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


mkdir -p /data/swap
cd /data/swap
#设置8G虚拟内存
dd if=/dev/zero of=/data/swap/swapfile1 bs=1M count=8192
#查看创建文件大小
du -sh /data/swap/swapfile1
#将目标文件标识为swap分区文件
mkswap /data/swap/swapfile1
#激活swap文件
swapon /data/swap/swapfile1
#写进配置文件
echo '/data/swap/swapfile1 swap swap defaults 0 0' >>/etc/fstab
#查看是否挂载成功
swapon -s

#删除swap空间
swapoff /data/swap/swapfile1
#同时删除/etc/fstab文件中的相关信息
#查看swap使用比例情况
cat /proc/sys/vm/swappiness
#临时修改使用比例
sysctl vm.swappiness=60
#内存在使用到100-60=40%的时候，就开始出现有交换分区的使用。
#注意：临时修改后，重启操作系统会重置默认值。
#永久修改使用比例
#vim  /etc/sysctl.conf
#在sysctl.conf文件中最后一行加入
vm.swappiness=60





#安装相关软件
lvm
yum -y install lvm2
ifconfig
yum -y install net-tools


#抓报错信息
grep -nE 'error|ERROR|FATAL|' *.log > collect.log

#格式化date
date "+%Y%m%d_%H%M%S"
date "+%Y-%m-%d"
date "+%H:%M:%S"
date "+%Y-%m-%d %H:%M:%S"
date "+%Y_%m_%d %H:%M:%S"  
date -d today 
date -d now
date -d tomorrow
date -d yesterday



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

#每十秒执行一次脚本
* * * * *  /home/gauss/1.sh >> 1.log
* * * * * sleep 10; /home/gauss/1.sh >> 1.log
* * * * * sleep 20; /home/gauss/1.sh >> 1.log
* * * * * sleep 30; /home/gauss/1.sh >> 1.log
* * * * * sleep 40; /home/gauss/1.sh >> 1.log
* * * * * sleep 50; /home/gauss/1.sh >> 1.log


#后台执行命令
nohup test.sh >> test.log 2>&1 &

#查看进程的线程资源使用情况
top -H -p  进程号
top -H -p <PID>


#测试磁盘的写速度
dd if=/dev/zero of=/dev/null

#查看端口占用情况
lsof -i:端口号
#查看进程号
ps -e|grep gaussdb
#根据进程号查看端口号
netstat -nap|grep 4498

# 检查多个包的安装情况
rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' bc
# cat输入重定向写文件
cat >file<<EOF
fasdfasd
asdfasdf
122131
1234534
fadfas
asfasdf
EOF
# 快速设置密码
echo password | passwd --stdin user
# 占用CPU的操作
cat /dev/zero
# 占用内存的操作
dd if=/dev/zero of=/dev/null bs=1024MB
# 造一个2G的文件
dd if=/dev/zero of=/root/test-file bs=1MB count=2000
# 语言变量
export LANG="zh_CN.UTF-8"
export LANG="en_US.UTF-8"

echo 'LANG=en_US.UTF-8' >> ~/.bash_profile
source ~/.bash_profile
# 一直执行的命令
while(true);do echo yaokang is a good boy!;sleep 1;done
#通过端口找进程ID
netstat -anp|grep 8081 | grep LISTEN|awk '{printf$7}'|cut -d/ -f1

# sed命令
sed -i 's///g' regular_express.txt

# 获取终端的ip地址
ip addr show ens33 | awk -F "[ /]+" '/inet /{print $3}'
ifconfig ens33 | awk -F "[ :]+" '/inet /{print $4}'

# 将当前文件夹下多级文件夹内的指定文件，移动到当前文件夹下
find ./ -name *.rpm -exec mv {} . \;

