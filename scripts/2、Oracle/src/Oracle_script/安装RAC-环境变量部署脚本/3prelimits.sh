#!/bin/bash
#Purpose:Change the /etc/security/limits.conf.
#Usage:Log on as the superuser('root'),and then execute the command:#./3prelimits.sh
#Author:Asher Huang

echo "Now modify the /etc/security/limits.conf,but backup it named /etc/security/limits.conf.bak before"
cp /etc/security/limits.conf /etc/security/limits.conf.bak
echo "oracle soft nproc 2047" >>/etc/security/limits.conf
echo "oracle hard nproc 16384" >>/etc/security/limits.conf
echo "oracle soft nofile 1024" >>/etc/security/limits.conf
echo "oracle hard nofile 65536" >>/etc/security/limits.conf
echo "grid soft nproc 2047" >>/etc/security/limits.conf
echo "grid hard nproc 16384" >>/etc/security/limits.conf
echo "grid soft nofile 1024" >>/etc/security/limits.conf
echo "grid hard nofile 65536" >>/etc/security/limits.conf
echo "Modifing the /etc/security/limits.conf has been succeed."
