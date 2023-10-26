#RHEL8环境设置
cat > /etc/hosts << "EOF"
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.190 mongo190
EOF
hostnamectl set-hostname mongo196
sed -i '/^UUID/d' /etc/sysconfig/network-scripts/ifcfg-ens33
nmcli con add con-name static ifname ens33 type ethernet ipv4.addresses 192.168.1.196/24 ipv4.gateway 192.168.1.1 ipv4.dns 192.168.1.1 ipv4.method manual
nmcli con up static


1）安装一套OS，装好后关机
2）通过虚拟机克隆多套
3）开机，改IP，改主机名，改hosts文件
systemctl set-default multi-user.target
#改主机名：
hostnamectl set-hostname red182
#改hosts文件配置
cat > /etc/hosts << "EOF"
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.1.180 red180
192.168.1.181 red181
192.168.1.182 red182
192.168.1.183 red183
192.168.1.184 red184
192.168.1.185 red185
192.168.1.186 red186

EOF

#修改IP配置文件信息 
vi /etc/sysconfig/network-scripts/ifcfg-ens33
#删除对应的UUID

#添加静态IP地址
nmcli con show
nmcli con add con-name static ifname ens33 type ethernet ipv4.addresses 192.168.1.182/24 ipv4.gateway 192.168.1.1 ipv4.dns 192.168.1.1 ipv4.method manual
nmcli con up static





#REHL8网络配置
#DHCP
nmcli con down ens160
nmcli con add con-name dhcp type ethernet ifname ens160
nmcli con up dhcp
ip a show ens160

nmcli con add con-name dhcp type ethernet ifname ens160
nmcli con show
nmcli con up dhcp
nmcli con down
nmcli con delete dhcp
nmcli con help
#手动地址
nmcli con add con-name ens256-2 ifname ens256 type ethernet ipv4.addresses 2.2.2.2/24 ipv4.gateway 2.2.2.200 ipv4.dns 8.8.8.8 ipv4.method manual
# 查看网卡地址
ip address show ens160





#若访问mirrors.aliyun.com很慢，配置dns解析
echo "nameserver 114.114.114.114" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 223.5.5.5" >> /etc/resolv.conf




mount /dev/cdrom /mnt

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
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum install -y htop
yum install -y telnet-server telnet
yum install -y unix2dos
yum install -y dos2unix



#http测试服务搭建
yum install -y httpd
systemctl restart httpd
systemctl status httpd
echo 'test' > /var/www/html/index.html
curl http://192.168.1.100/index.html



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




#lvm 创建文件系统
pvcreate /dev/sdb
vgcreate oravg /dev/sdb
lvcreate -n oralv -L 190G oravg
mkfs.ext4 /dev/oravg/oralv

pvs
vgs/vgdisplay
lvs/lvdisplay

mkdir -p /oracle

cat >> /etc/fstab << "EOF"
/dev/oravg/oralv /oracle ext4 defaults 0 0
EOF

mount -a





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




