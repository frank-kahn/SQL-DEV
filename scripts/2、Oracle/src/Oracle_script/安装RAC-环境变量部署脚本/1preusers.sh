#!/bin/bash
#Purpose:Create 6 groups named 'oinstall','dba','asmadmin','asmdba','asmoper','oper', plus 2 users named 'oracle','grid'.
#Also setting the Environment
#variable for oracle user.
#variable for grid user.
#Usage:Log on as the superuser('root'),and then execute the command:#./1preusers.sh
#Author:Asher Huang

echo "Now create 6 groups named 'oinstall','dba','asmadmin','asmdba','asmoper','oper'"
echo "Plus 2 users named 'oracle','grid',Also setting the Environment"


groupadd -g 1200 oinstall 
groupadd -g 1203 asmadmin 
groupadd -g 1201 asmdba 
groupadd -g 1202 asmoper 
groupadd -g 1300 dba 
groupadd -g 1301 oper
useradd -u 1200 -g oinstall -G asmadmin,asmdba,asmoper,dba -d /home/grid -s /bin/bash -c "grid Infrastructure Owner" grid 
echo "grid" | passwd --stdin grid

echo 'export PS1="`/bin/hostname -s`-> "'>> /home/grid/.bash_profile 
echo "export TMP=/tmp">> /home/grid/.bash_profile  
echo 'export TMPDIR=$TMP'>>/home/grid/.bash_profile 
echo "export ORACLE_SID=+ASM2">> /home/grid/.bash_profile 
echo "export ORACLE_BASE=/u01/app/grid">> /home/grid/.bash_profile
echo "export ORACLE_HOME=/u01/app/11.2.0/grid">> /home/grid/.bash_profile
echo "export ORACLE_TERM=xterm">> /home/grid/.bash_profile
echo "export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'" >> /home/grid/.bash_profile
echo 'export TNS_ADMIN=$ORACLE_HOME/network/admin'  >> /home/grid/.bash_profile
echo 'export PATH=/usr/sbin:$PATH'>> /home/grid/.bash_profile
echo 'export PATH=$ORACLE_HOME/bin:$PATH'>> /home/grid/.bash_profile
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib'>> /home/grid/.bash_profile
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib'>> /home/grid/.bash_profile
echo "export EDITOR=vi" >> /home/grid/.bash_profile
echo "export LANG=en_US" >> /home/grid/.bash_profile
echo "export NLS_LANG=american_america.AL32UTF8" >> /home/grid/.bash_profile
echo "umask 022">> /home/grid/.bash_profile

 
useradd -u 1100 -g oinstall -G dba,oper,asmdba -d /home/oracle -s /bin/bash -c "Oracle Software Owner" oracle 
echo "oracle" | passwd --stdin oracle

echo 'export PS1="`/bin/hostname -s`-> "'>> /home/oracle/.bash_profile 
echo "export TMP=/tmp">> /home/oracle/.bash_profile  
echo 'export TMPDIR=$TMP'>>/home/oracle/.bash_profile 
echo "export ORACLE_HOSTNAME=racdb2">> /home/oracle/.bash_profile 
echo "export ORACLE_SID=racdb2">> /home/oracle/.bash_profile 
echo "export ORACLE_BASE=/u01/app/oracle">> /home/oracle/.bash_profile
echo 'export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1'>> /home/oracle/.bash_profile
echo "export ORACLE_UNQNAME=racdb">> /home/oracle/.bash_profile
echo 'export TNS_ADMIN=$ORACLE_HOME/network/admin'  >> /home/oracle/.bash_profile
echo "export ORACLE_TERM=xterm">> /home/oracle/.bash_profile
echo 'export PATH=/usr/sbin:$PATH'>> /home/oracle/.bash_profile
echo 'export PATH=$ORACLE_HOME/bin:$PATH'>> /home/oracle/.bash_profile
echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib'>> /home/oracle/.bash_profile
echo 'export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib'>> /home/oracle/.bash_profile
echo "export EDITOR=vi" >> /home/oracle/.bash_profile
echo "export LANG=en_US" >> /home/oracle/.bash_profile
echo "export NLS_LANG=american_america.AL32UTF8" >> /home/oracle/.bash_profile
echo "export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'" >> /home/oracle/.bash_profile
echo "umask 022">> /home/oracle/.bash_profile

echo "The Groups and users has been created"
echo "The Environment for grid,oracle also has been set successfully"
