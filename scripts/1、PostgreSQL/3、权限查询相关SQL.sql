-- 实例权限pg_hba.conf
select to_char(now(),'yyyy-mm-dd hh24:mi:ss') "巡检时间"
      ,line_number "line_number(行号)"
      ,type "type(连接类型)"
      ,database "database(数据库名)"
      ,user_name "user_name(用户名)"
      ,address "address(ip地址)"
      ,netmask "netmask(子网掩码)"
      ,auth_method "auth_method(认证方式)"
  from pg_hba_file_rules
 order by "line_number(行号)";


-- 数据库权限
select d.datname as "database"
      ,pg_catalog.pg_get_userbyid(d.datdba) as "Owner"
      ,d.datacl AS "Access privileges"
  FROM pg_catalog.pg_database d;


-- 模式权限
SELECT n.nspname AS "schema"
      ,pg_catalog.pg_get_userbyid(n.nspowner) AS "Owner"
      ,n.nspacl AS "Access privileges"
  FROM pg_catalog.pg_namespace n
 WHERE n.nspname !~ '^pg_' 
   AND n.nspname <> 'information_schema'
 ORDER BY 1;


-- 表的权限
select t2.nspname as "schema"
      ,t1.relname as "tablename"
      ,t3.usename as "table_owner"
      ,t1.relacl
  from pg_class t1,pg_namespace t2,pg_user t3
 where t1.relnamespace=t2.oid
   -- and t1.relname = 'test_t'
   and t1.relowner=t3.usesysid;


-- 列的权限
select t2.relname
      ,t1.attname
      ,t1.attacl
  from pg_attribute t1
      ,pg_class t2
 where t1.attrelid=t2.oid
   -- and t2.relname='test_t'
   and t1.attnum>0;


-- 表空间权限
select to_char(now(),'yyyy-mm-dd hh24:mi:ss') "巡检时间"
      ,spcname AS "Name(名称)"
      ,pg_catalog.pg_get_userbyid(spcowner) AS "Owner(拥有者)"
      --,pg_catalog.pg_tablespace_location(oid) AS "Location(数据文件目录)"
      ,pg_catalog.array_to_string(spcacl, E'\n') AS "Access privileges(访问权限)"
      --,spcoptions AS "Options(参数)"
      ,pg_catalog.pg_size_pretty(pg_catalog.pg_tablespace_size(oid)) AS "Size(表空间大小)"
      --,pg_catalog.shobj_description(oid, 'pg_tablespace') AS "Description(备注)"
  from pg_catalog.pg_tablespace
 order by 1;


-- 函数或存储过程的权限
pg_proc.proacl
GRANT EXECUTE ON FUNCTION function_name(argument_types) TO username;
GRANT EXECUTE ON FUNCTION my_function(text) TO myuser;

-- 类型的权限
pg_type.typacl

-- 开发语言的权限
pg_language.lanacl



权限	       缩写	     使用对象类型
select	       r	     large object，sequence，table（and table-like objects），table column
insert	       a	     table，table column
update	       w	     large object，sequence，table，table column
delete	       d	     table
truncate	   D	     table
references	   x	     table，table column
trigger	       t	     table
create	       C	     database，schema，tablespace
connect	       c	     database
temporary	   T	     database
execute	       X	     function，procedure
usage	       U	     domain，foreign data wrapper，Foreign server，language，schema，sequence，type


对象类型	                        所有权限	默认public权限	psql命令
database	                        CTc	        Tc	            \l
domain	                            U	        U	            \dD+
function or procedure	            X           X	            \df+
foreign data wrapper	            U           none	        \dew+
foreign server	                    U	        none	        \des+
language	                        U	        U	            \dL+
large object	                    rw	        none	        
schema	                            UC	        none	        \dn+
sequence	                        rwU	        none	        \dp
table（and table-like objects）	arwdDxt	    none	        \dp
table column	                    arwx	    none	        \dp
tablespace	                        C	        none	        \db+
type	                            U	        U	            \dT+













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

-- 默认权限
alter default privileges for role test_user in schema test revoke all on functions from public;

-- PostgreSQL 设置用户绕过RLS（行级安全策略）
alter user <user_name> BYPASSRLS;

-- 普通用户想要修改其他用户的密码需要什么权限
alter user test createrole;



-- 备份postgresql用户的密码
select 'alter role '|| usename || ' with password ' || '''' || passwd || ''';' from pg_shadow;