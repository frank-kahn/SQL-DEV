#############################################################################################
#                                       CentOS 7.6
#############################################################################################
#环境准备参考
https://blog.csdn.net/myneth/article/details/132528842


#语言环境设置
echo 'export LANG=en_US.UTF-8' >> /etc/profile
source /etc/profile

#改主机名：
hostnamectl set-hostname testosb
#改hosts文件配置
cat >> /etc/hosts << EOF
192.168.1.101 testos1
EOF
#修改IP配置文件信息 
sed -i '/IPADDR/s/192.168.1.100/192.168.1.91/' /etc/sysconfig/network-scripts/ifcfg-ens33
#修改IP信息，同时删除对应的UUID
sed -i '/^UUID/d' /etc/sysconfig/network-scripts/ifcfg-ens33
#重启网络服务
systemctl restart network



#linux 7 yum配置
mount /dev/cdrom /mnt
cd /etc/yum.repos.d
mkdir bk
mv *.repo bk/

cat >test.repo<<EOF
[EL7]
name = linux 7.6 dvd
baseurl=file:///mnt
gpgcheck=0
enabled=1
EOF

#安装常见工具
yum install -y tree
yum install -y net-tools
yum install -y vim
yum install -y python3
yum install -y expect
yum install -y lsof
yum install -y wget
yum install -y mlocate
yum install -y lvm2
yum install -y lrzsz
yum install -y telnet-server telnet
yum install -y unix2dos
yum install -y dos2unix

#rlwrap
wget https://gitcode.net/myneth/tools/-/raw/master/tool/rlwrap_0.42.tar.gz
tar -zxvf rlwrap_0.42.tar.gz
rpm -ivh ncurses-devel-5.9-14.20130511.el7_4.x86_64.rpm
rpm -ivh readline-devel-6.2-10.el7.x86_64.rpm
tar -zxvf rlwrap-0.42.tar.gz
cd rlwrap-0.42
./configure
make
make install

#htop
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum install -y htop



#ssh直连慢
grep -i "usedns" /etc/ssh/sshd_config
sed -ir '/^#UseDNS/s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
grep -i "usedns" /etc/ssh/sshd_config
service sshd restart
systemctl restart sshd



#若访问mirrors.aliyun.com很慢，配置dns解析
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 223.5.5.5" >> /etc/resolv.conf

#http测试服务搭建
yum install -y httpd
systemctl restart httpd
systemctl status httpd
echo 'test' > /var/www/html/index.html
curl http://192.168.1.100/index.html


#linux 8 yum配置
mount /dev/cdrom /mnt
cd /etc/yum.repos.d
mkdir bk
mv *.repo bk/
cat >rhel8.repo<<EOF
[AppStream]
name = AppStream's repo
enable = yes
gpgcheck = 0
baseurl = file:///mnt/AppStream

[BaseOS]
name = BaseOS's repo
enable = yes
gpgcheck = 0
baseurl = file:///mnt/BaseOS

EOF


#在线yum源配置

[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=0
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-7

#更新软件包缓存
yum makecache


#Centos 7.6 图像界面安装
yum groupinstall -y "X Window System"
yum groupinstall -y "GNOME Desktop" "Graphical Administration Tools"

#Centos 8.2 图像界面安装
yum groupinstall -y "Server with GUI"


#############################################################################################
#                                       Debian系统
#############################################################################################

# Debian系统 配置软件源  安装软件
https://www.xmmup.com/debiangebanbendaihaojianjiejijingxiangyuanpeizhi.html

https://mirrors.tuna.tsinghua.edu.cn/help/debian/

cp /etc/apt/sources.list /etc/apt/sources.list_bk
cat > /etc/apt/sources.list <<"EOF"
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

apt-get update -y
apt-get install procps -y
apt-get install vim lsof tree -y
apt-get install net-tools




