# 创建用户
groupadd -g 60001 postgres
useradd -u 60001 -g postgres postgres
echo postgres | passwd --stdin postgres
# 创建目录
mkdir -p /postgresql/{pgdata,archive,scripts,backup,pg12,soft}
chown -R postgres:postgres /postgresql
chmod -R 775 /postgresql

# 一些依赖包
yum install -y cmake make gcc zlib gcc-c++ perl readline readline-devel zlib zlib-devel perl python36 tcl openssl ncurses-devel openldap pam
yum install -y openssl openssl-devel


# 编译和安装
./configure  --prefix=/postgresql/pg12 --with-pgport=5432 \
--with-blocksize=8 \
--with-wal-blocksize=8 \
--with-segsize=8 \
--with-openssl

make -j 4
make install

# 配置环境变量
su - postgres

cat >>  ~/.bash_profile << "EOF"
export LANG=en_US.UTF-8
export PS1="[\u@\h \W]\$ "
export PGPORT=5432
export PGDATA=/postgresql/pgdata
export PGHOME=/postgresql/pg12
export LD_LIBRARY_PATH=$PGHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH:.
export DATE=`date +"%Y%m%d%H%M"`
export MANPATH=$PGHOME/share/man:$MANPATH
export PGHOST=$PGDATA
export PGUSER=postgres
export PGDATABASE=postgres
#alias psql='rlwrap psql'
EOF

source ~/.bash_profile

#初始化
/postgresql/pg12/bin/initdb -D /postgresql/pgdata -E UTF8 --locale=en_US.utf8 -U postgres

#基本参数修改
cat >> /postgresql/pgdata/postgresql.conf << EOF
listen_addresses = '*'
port = 5432
unix_socket_directories = '/postgresql/pgdata'
logging_collector = on
log_directory = 'pg_log'
#log_filename = 'postgresql-%a.log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_truncate_on_rotation = on
EOF

#配置白名单
cat > /postgresql/pgdata/pg_hba.conf << EOF
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0               md5
host    replication     all             0.0.0.0/0               md5
EOF