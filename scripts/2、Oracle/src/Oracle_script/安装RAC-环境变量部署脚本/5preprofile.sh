#!/bin/bash
#Purpose:Modify the /etc/profile.
#Usage:Log on as the superuser('root'),and then execute the command:#./5preprofile.sh
#Author:Asher Huang

echo "Now modify the  /etc/profile,but with a backup named  /etc/profile.bak"
cp /etc/profile /etc/profile.bak
echo 'if [ $USER = "oracle" ]||[ $USER = "grid" ]; then' >>  /etc/profile
echo 'if [ $SHELL = "/bin/ksh" ]; then' >> /etc/profile
echo 'ulimit -p 16384' >> /etc/profile
echo 'ulimit -n 65536' >> /etc/profile
echo 'else' >> /etc/profile
echo 'ulimit -u 16384 -n 65536' >> /etc/profile
echo 'fi' >> /etc/profile
echo 'fi' >> /etc/profile
echo "Modifing the /etc/profile has been succeed."
