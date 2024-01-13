-- 数据库权限授予
grant all privileges on database testdb to user1;
grant create,connect,temporary on database testdb to user1;


-- 模式权限授予
grant usage on schema test_schema to user1;
grant all privileges on schema test_schema to user1;
-- 模式下的对象授权
grant all privileges on all tables    in schema test_schema to user1;
grant all privileges on all sequences in schema test_schema to user1;
grant all privileges on all functions in schema test_schema to user1;
-- 模式下的对象权限回收
revoke all privileges on all tables    in schema test_schema from user1;
revoke all privileges on all sequences in schema test_schema from user1;
revoke all privileges on all functions in schema test_schema from user1;
-- 模式下新增对象的默认权限
alter default privileges in schema test_schema grant all privileges on tables to user1;
alter default privileges in schema test_schema grant all privileges on sequences to user1;
alter default privileges in schema test_schema grant all privileges on functions to user1;
-- 模式下默认权限回收
alter default privileges for role test_user in schema test_schema revoke all on functions from public;
alter default privileges in schema test_schema revoke all on tables from user1;
alter default privileges in schema test_schema revoke all on sequences from user1;
alter default privileges in schema test_schema revoke all on functions from user1;



----------------------------------------------------- 添加只读用户 -------------------------------------------------------
-- 1、创建用户及指定密码：
create user readonly with encrypted password 'readonly';
-- 2、设置用户默认事务只读：
alter user readonly set default_transaction_read_only=on;
-- 3、赋予用户连接数据库权限：
grant connect on database foo to readonly;
-- 4、切换到指定数据库：
\c foo
-- 5、赋予用户权限，查看public模式下所有表：
grant usage on schema public to readonly;
alter default privileges in schema public grant select on tables to readonly;
-- 6、赋予指定模式下用户表、序列查看权限：
grant usage on schema test_schema to readonly;
grant select on all sequences in schema test_schema to readonly;
grant select on all tables in schema test_schema to readonly;
alter default privileges in schema test_schema grant select on tables to readonly;



----------------------------------------------------------  修改属主 -------------------------------------------------------
-- 修改database属主
alter database testdb owner to root;
-- 修改schema的属主
alter schema schema_name owner to new_owner;
-- 修改schema 下特定表的属主
alter table schema_name.table_name owner to new_owner;


---------------------------------------------------------  删除用户  --------------------------------------------------------
\dt
\dn
drop schema test cascade;
drop database testdb;

##用户下面无对象
error：role "xxx" cannot be dropped because some object depend on it
detail: privileges for database xxxx
#更改数据库角色拥有的数据库对象的所有权
---- 1、如果不保留owner的数据库对象
reassign owned by test_user to postgres;
drop owned by test_user;
drop role test_user;
---- 2、如果保留owner的数据库对象
reassign owned by test_user to postgres;
drop role test_user;
---- 3、如果还要删除数据库
drop database testdb;


##用户下面有对象
error：role "xxx" cannot be dropped because some object depend on it
detail: 24 objects in database xxxx

select * from information_schema.table_privileges where grantee='test_user';
revoke all on all tables in schema public from test_user;
alter default privileges in schema public revoke all on tables from test_user;
alter default privileges in schema public revoke all on sequences from test_user;
-------------------------------------------------------------------------------------------------------------------------------


-- postgresql 设置用户绕过rls（行级安全策略）
alter user <user_name>  bypassrls; 



