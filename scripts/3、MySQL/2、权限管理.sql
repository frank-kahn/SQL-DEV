-- 备份MySQL用户的密码
select concat('alter user \'',user,'\'@\'',host,'\' identified with \'mysql_native_password\' as ','\'',authentication_string,'\';') from mysql.user;

-- mysql 密码验证
-- 5.7版本
select host,user,plugin,authentication_string,password('rootroot') from mysql.user where user='root';
-- 8.0版本
select host,user,plugin,authentication_string,sha('rootroot') from mysql.user where user='root';



-- 刷权限
flush privileges;