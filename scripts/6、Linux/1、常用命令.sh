sed课程
https://edu.51cto.com/center/course/lesson/index?id=306465

Linux入门学习教程-2019全新正则表达式及vim进阶
https://edu.51cto.com/course/15296.html

马哥教育2016Linux培训教程-awk命令
https://edu.51cto.com/course/5542.html


#Linux 磁盘空间满了，但是实际目录文件占用空间并没有那么大
https://www.cnblogs.com/js1314/p/14179017.html


#######################################################################################
#####                                      swap
#######################################################################################
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




#查看端口占用情况
lsof -i:端口号
#查看进程号
ps -e|grep gaussdb
#根据进程号查看端口号
netstat -nap|grep 4498
#通过端口找进程ID
netstat -anp|grep 8081 | grep LISTEN|awk '{printf$7}'|cut -d/ -f1

# 检查多个包的安装情况
rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' bc

# 快速设置密码
echo password | passwd --stdin user


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
#显示毫秒
date "+%Y-%m-%d %H:%M:%S.%3N"


#iptables
iptables -VnL