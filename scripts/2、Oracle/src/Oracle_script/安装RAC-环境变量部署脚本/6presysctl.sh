#!/bin/bash
#Purpose:Modify the /etc/sysctl.conf.
#Usage:Log on as the superuser('root'),and then execute the command:#./6presysctl.sh
#Author:Asher Huang

echo "Now modify the /etc/sysctl.conf,but with a backup named /etc/sysctl.bak"
cp /etc/sysctl.conf /etc/sysctl.conf.bak

echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
echo "fs.file-max = 6815744" >> /etc/sysctl.conf
echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
echo "kernel.shmmax = 4294967295" >> /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.wmem_max = 1048586" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 262144 262144 262144" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4194304 4194304 4194304" >> /etc/sysctl.conf

echo "Modifing the /etc/sysctl.conf has been succeed."
echo "Now make the changes take effect....."
sysctl -p
