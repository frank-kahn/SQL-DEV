-- 创建用户
create user test_user identified by test;
alter user test_user quota unlimited on users;
grant connect,resource to test_user;

------------------------------------------常用权限授予----------------------------------
-- 给用户授权所有数据字典的查询权限
grant select any dictionary to test_user;
-- 数据泵需要使用的权限
grant datapump_exp_full_database to test01;
-- 杀会话的权限
GRANT ALTER SYSTEM TO <username>;


-- 获取某个用户的全部权限：系统权限、对象权限
-- 对象权限
select OWNER,TABLE_NAME,GRANTOR,PRIVILEGE from dba_tab_privs where GRANTEE='TEST_USER';
select 'grant '||t.privilege||' on '||t.owner||'.'||t.table_name||' to '||t.grantee||decode(grantable,'YES','with grant option','')||';'
 from dba_tab_privs t
 where t.grantee in ('TEST1','TEST2');
-- 系统权限
select 'grant '||t.privilege||' to '||t.grantee||';'
 from dba_sys_privs t
 where t.grantee in ('TEST1','TEST2');


-- 检查用户所有的系统权限（系统权限和角色权限都要查询）
SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT','TEST_USER') from dual
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT','TEST_USER') from dual;

select PRIVILEGE from dba_sys_privs t where t.grantee = 'TEST_USER'
union
select PRIVILEGE from ROLE_SYS_PRIVS where role in (select GRANTED_ROLE from DBA_ROLE_PRIVS where grantee = 'TEST_USER');



-- 查看用户下拥有的表
select OWNER,TABLE_NAME,TABLESPACE_NAME from all_tables where OWNER='TEST_USER';


-- 批量授权
create or replace procedure grantqx(v_from in varchar2, v_to in varchar2) is
v_sql varchar2(1000);
cursor v_cur is
select t.* from dba_tables t where t.OWNER = v_from;
begin
for v_row in v_cur loop
v_sql := 'grant select on ' || v_from || '.' || v_row.table_name ||' to ' || v_to;
execute immediate v_sql;
end loop;
end grantqx;


DECLARE
v_sql varchar2(1000);
cursor v_cur is
select t.* from dba_tables t where t.OWNER = 'TEST_USER';
begin
for v_row in v_cur loop
v_sql := 'grant select on ' || 'TEST_USER' || '.' || v_row.table_name ||' to ' || 'YAOKANG';
DBMS_OUTPUT.ENABLE;
DBMS_OUTPUT.PUT_LINE(v_sql);
-- execute immediate v_sql;
end loop;
end;
/


select OWNER,TABLE_NAME,GRANTOR,PRIVILEGE from dba_tab_privs where regexp_like(TABLE_NAME,'^test_t','i');


-- 查询Oracle系统schema
select username from dba_users where default_tablespace in ('SYSTEM','SYSAUX');
