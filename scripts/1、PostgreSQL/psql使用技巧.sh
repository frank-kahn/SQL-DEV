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