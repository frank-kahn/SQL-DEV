# 连接到MySQL并设置提示符包括会话ID
MYSQL_CONN_ID=$(mysql -uroot -prootroot -sse "SELECT CONNECTION_ID()")
mysql -uroot -prootroot --prompt="mysql($MYSQL_CONN_ID) [\d]> "
mysql -uroot -prootroot --prompt="mysql($MYSQL_CONN_ID) "