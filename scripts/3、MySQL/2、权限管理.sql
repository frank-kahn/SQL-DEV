-- 备份MySQL用户的密码
select concat('alter user \'',user,'\'@\'',host,'\' identified with \'mysql_native_password\' as ','\'',authentication_string,'\';') from mysql.user;

