#!/bin/bash
#Purpose:Modify the /etc/pam.d/login.
#Usage:Log on as the superuser('root'),and then execute the command:#./4prelimits.sh
#Author:Asher Huang

echo "Now modify the /etc/pam.d/login,but with a backup named /etc/pam.d/login.bak"
cp /etc/pam.d/login /etc/pam.d/login.bak

echo "session required /lib/security/pam_limits.so" >>/etc/pam.d/login
echo "session required pam_limits.so" >>/etc/pam.d/login

echo "Modifing the /etc/pam.d/login has been succeed."

