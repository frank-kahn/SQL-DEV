--查看某用户的系统权限 
SELECT * FROM pg_roles WHERE rolname='test';
--查看某用户的表权限 
select * from information_schema.table_privileges where grantee='test'; 
--查看某用户的usage权限 
select * from information_schema.usage_privileges where grantee='test'; 
--查看某用户在存储过程函数的执行权限 
select * from information_schema.routine_privileges where grantee='test'; 
--查看某用户在某表的列上的权限 
select * from information_schema.column_privileges where grantee='test'; 
--查看当前用户能够访问的数据类型 
select * from information_schema.data_type_privileges ; 
--查看用户自定义类型上授予的USAGE权限 
select * from information_schema.udt_privileges where grantee='test';
--查看一个表的授权信息
SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name='test_tb';