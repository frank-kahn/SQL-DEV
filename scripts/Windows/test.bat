mysqldump --routines --events --single-transaction --databases fgedu -u root -prootroot > fgedu.sql
--routines 表示导出存储过程和自定义的函数
--events  表示导出事件
--single-transaction  不会阻塞任何程序，而且保证数据的一致性（innodb）


mysql -hlocalhost -uroot -prootroot --max-allowed-packet=1G < fgedu.sql

https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.43-linux-glibc2.12-x86_64.tar.gz

cat >> /etc/hosts << EOF
192.168.1.10 centos7.6
EOF


4-6   7.4.6.
4-7   7.4.7.MySQL性能优化之执行计划Explain
4-8   7.4.8.MySQL性能优化之Profile
4-9   7.4.9.索引优化工具SQLAdvisor使用
4-10   7.4.10.MySQL数据库索引优化案例
4-11   7.4.11.MySQL性能优化之SQL优化编写经验
4-12   7.4.12.MySQL性能调整与优化建议工具

www.itpux7704.com
www.itpux04.com
www.itpux.com
www.fgedu.net.cn
dba:www.fgedu.net.cn





