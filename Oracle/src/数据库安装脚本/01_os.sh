
###############sysctl.conf#####################
echo "config sysctl.conf ..."
cp /etc/sysctl.conf /etc/sysctl.conf_bak
mem=$(free -g | grep Mem | awk {'print $2'})
shm=$((mem*1024*1024*819))
mall=$((shm/4096))

cat <<eof >> /etc/sysctl.conf
##oracle parameter
kernel.shmmni = 4096
kernel.shmall = $mall   
kernel.shmmax = $shm
fs.aio-max-nr = 1048576
fs.file-max = 6815744
#fs.aio-max-nr = 4194304
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
net.ipv4.ipfrag_high_thresh = 16777216
net.ipv4.ipfrag_low_thresh = 15728640
kernel.panic_on_oops = 1
kernel.randomize_va_space = 0
vm.min_free_kbytes= 524288
vm.swappiness =10
eof

###############lmits.conf#####################
echo "config limits.conf ..."
cp /etc/security/limits.conf /etc/security/limits.conf_bak
cat <<eof >> /etc/security/limits.conf
# Controls the Oracle parameters
##oracle parameter
oracle soft memlock unlimited
oracle hard memlock unlimited
oracle soft nproc 16384
oracle hard nproc 16384
oracle soft nofile 65536
oracle hard nofile 65536
oracle soft stack 10240
eof



###############system#####################
echo "disable firewalld avahi-daemon bluetooth ..."
systemctl stop firewalld
systemctl stop avahi-daemon
systemctl stop  bluetooth
systemctl disable firewalld
systemctl disable  avahi-daemon
systemctl disable  bluetooth



###############add user#####################
echo "useradd user ..."
groupadd -g 310 dba
groupadd -g 311 oinstall
groupadd -g 312 oper
useradd -u 500 -g oinstall -G dba,oper oracle
echo "oracle" | passwd --stdin oracle


###############config bash_profile#####################
echo "add bash_profile ..."
cat <<eof >> /home/oracle/.bash_profile
export ORACLE_BASE=/oracle/app/oracle
export ORACLE_HOME=/oracle/app/oracle/product/11.2/db
export PATH=$PATH:$ORACLE_HOME/bin:$ORACLE_HOME/OPatch
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export ORACLE_SID=INSTANCE_NAME
alias cdo='cd $ORACLE_HOME'
alias cdb='cd $ORACLE_HOME/dbs'
alias cdn='cd $ORACLE_HOME/network/admin'
alias cdal='cd $ORACLE_BASE/diag/rdbms/*/*/trace'
alias sqp='sqlplus / as sysdba'
eof

###############config bash_profile#####################
mkdir -p /oracle/app/oracle/product/11.2/db
mkdir -p /oradata
mkdir -p /oraarch
mkdir -p /orabak/{rmanbak,expdpbak,awr,scripts,utl_file}

###############config chown#####################
chown -R oracle:oinstall /oracle
chown -R oracle:oinstall /oradata
chown -R oracle:oinstall /oraarch
chown -R oracle:oinstall /orabak






