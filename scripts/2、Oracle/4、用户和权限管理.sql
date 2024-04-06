-- 创建用户
create user yaokang identified by yaokang;
alter user yaokang quota unlimited on users;
grant connect,resource to yaokang;


-- 给用户授权所有数据字典的查询权限
grant select any dictionary to test_user;

-- 数据泵需要使用的权限
grant datapump_exp_full_database to test01;

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
