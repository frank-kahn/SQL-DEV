--1.查看所有用户：
select * from dba_users;  
select * from all_users;  
select * from user_users; 

--2.查看用户或角色系统权限(直接赋值给用户或角色的系统权限)：
select * from dba_sys_privs;  
select * from user_sys_privs; 

--3.查看角色(只能查看登陆用户拥有的角色)所包含的权限
select * from role_sys_privs; 

--4.查看用户对象权限：
select * from dba_tab_privs;  
select * from all_tab_privs;  
select * from user_tab_privs; 

--5.查看所有角色：
select * from dba_roles; 

--6.查看用户或角色所拥有的角色：
select * from dba_role_privs;  
select * from user_role_privs; 

--7.查看哪些用户有sysdba或sysoper系统权限(查询时需要相应权限)
select * from V$PWFILE_USERS