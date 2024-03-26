#!/bin/bash
#Purpose:Create the necessary directory for oracle,grid users and change the authention to oracle,grid users.
#Usage:Log on as the superuser('root'),and then execute the command:#./2predir.sh
#Author:Asher Huang

echo "Now create the necessary directory for oracle,grid users and change the authention to oracle,grid users..."
mkdir -p /u01/app/grid 
mkdir -p /u01/app/11.2.0/grid 
mkdir -p /u01/app/oracle 
chown -R oracle:oinstall /u01
chown -R grid:oinstall /u01/app/grid 
chown -R grid:oinstall /u01/app/11.2.0
chmod -R 775 /u01
echo "The necessary directory for oracle,grid users and change the authention to oracle,grid users has been finished"
