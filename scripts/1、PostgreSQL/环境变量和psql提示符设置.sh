#用户名@IP:Port/数据库名(PID)
cd
cat >> ~/.psqlrc << "EOF"
\set PROMPT1 '%n@%M:%>/%/(%p)%R%#'
EOF

#用户名@数据库名
\set PROMPT1 '%n@%/%R%#'

#用户名@数据库名(PID)
\set PROMPT1 '%n@%/(%p)%R%#'

#数据库名(PID)
\set PROMPT1 '%/(%p)%R%#'

#数据库名
\set PROMPT1 '%/%R%#'


#修改会话级别日志参数，把日志输出到控制台上
set log_statement='all';  
set client_min_messages ='log';


#PostgreSQL环境变量

export LANG=en_US.UTF8
export PS1="[`whoami`@`hostname`:"'$PWD]$'
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
alias psql="rlwrap psql"

################################################ 提示符参数资料 #######################################################
--psql显示设置

Windows配置：
	%APPDATA%\postgresql\psqlrc.conf
Linux:
	psql会尝试依次从系统级的启动文件（psqlrc）和用户的个人启动文件（~/.psqlrc）中读取并且执行命令。
	修改postgres用户home(cd ~)路径下的隐藏文件.psqlrc(没有就手动创建一个)

\set PROMPT1 '%n@%M:%>/%/(%p)%R%#'				--用户名@IP:Port/数据库名(PID)

--测试
psql -h localhost -U postgres


%n
	数据库会话的用户名（在数据库会话期间，这个值可能会因为命令SET SESSIONAUTHORIZATION的结果而改变）。
%M
数据库服务器的完整主机名（带有域名），或者当该连接是建立在一个 Unix 域套
接字上时则是[local]，或者当 Unix 域套接字不在编译在系统内的默认位置上时则
是[local:/dir/name]。
%>
	数据库服务器正在监听的端口号。
%/
	当前数据库的名称。
%m
	数据库服务器的主机名称（在第一个点处截断），或者当连接建立在一个 Unix 域套接字上时是[local]。
%p
	当前连接到的后端的进程 ID。
%R
	在提示符1下通常是=，但如果会话位于一个条件块的一个非活动分支中则是@，如果会话
	处于单行模式中则是^，如果会话从数据库断开连接（\connect失败时会发生这种情况）
	则是!。在提示符 2 中，根据为什么psql期待更多的输入，%R会被一个相应的字符替
	换：如果命令还没有被终止是-，如果有一个未完的/* ... */注释则是*，如果有一个未
	完的被引用字符串则是一个单引号，如果有一个未完的被引用标识符则是一个双引号，
	如果有一个未完的美元引用字符串则是一个美元符号，如果有一个还没有被配对的左圆
	括号则是(。在提示符 3 中%R不会产生任何东西。
%#
	如果会话用户时一个数据库超级用户，则是#，否则是一个>（在数据库会话期间，这个
	值可能会因为命令SET SESSION AUTHORIZATION的结果而改变）。
%~
	和%/类似，但是如果数据库是默认数据库时输出是~（波浪线）。
%x
	事务状态：当不在事务块中时是一个空字符串，在一个事务块中时是*，在一个失败的事
	务块中时是!，当事务状态是未判定时（例如因为没有连接）为?。
%l
	当前语句中的行号，从1开始。




















