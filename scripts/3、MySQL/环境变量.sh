# 连接到MySQL并设置提示符包括会话ID
MYSQL_CONN_ID=$(mysql -uroot -prootroot -sse "SELECT CONNECTION_ID()")
mysql -uroot -prootroot --prompt="mysql($MYSQL_CONN_ID) [\d]> "
mysql -uroot -prootroot --prompt="mysql($MYSQL_CONN_ID) "


#######################  提示符 #########################
### 用户名@主机名[数据库名]>

~~~shell
[mysql]
prompt="\U [\d]> "

#或者
--prompt="\U [\d]> "
~~~

### 用户名 [数据库名]>

~~~shell
[mysql]
prompt="\u [\d]> "

#或者
--prompt="\u [\d]> "
~~~

### 用户名 [数据库名] 时分秒>

~~~shell
[mysql]
prompt="\u [\d] \R:\m:\s> "

#或者
--prompt="\u [\d] \R:\m:\s> "
~~~

### `用户名 [数据库名](会话ID)>`

~~~shell
mysql> select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              69 |
+-----------------+
1 row in set (0.00 sec)

mysql> prompt \u [\d](69)> 
PROMPT set to '\u [\d](69)> '
root [(none)](69)> 
~~~

### `用户名@主机名[数据库名](会话ID)>`

~~~sql
mysql> select connection_id();
+-----------------+
| connection_id() |
+-----------------+
|              70 |
+-----------------+
1 row in set (0.00 sec)

mysql> prompt \U [\d](70)>
PROMPT set to '\U [\d](70)>'
root@localhost [(none)](70)>
~~~


