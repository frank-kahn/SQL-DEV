# Oracle schema下线流程

## 1、锁定用户

~~~sql
-- 查杀用户连接信息
select DISTINCT 'alter system kill session '''||a.sid||','||a.serial#||',@'||a.inst_id||''' immediate;' as si_id
 from gv$session a
 where username='用户名';

-- 锁定用户
alter user 用户名 account lock;

-- 查询用户状态
select USERNAME,ACCOUNT_STATUS,LOCK_DATE,DEFAULT_TABLESPACE,PROFILE from dba_users where USERNAME='用户名';
~~~



## 2、回收用户权限

~~~shell
sqlplus -s / as sysdba << "EOF"
set trimspool on
set head off
set feedback off
set newp none
set linesize 3000
spool revoke_privileges_$ORACLE_SID.sql
select 'revoke '||t.privilege||' on '||t.owner||'.'||t.table_name||' from '||t.grantee||';'
 from dba_tab_privs t
 where t.owner in ('用户1','用户2');
select 'revoke '||t.privilege||' from '||t.grantee||';'
 from dba_sys_privs t
 where t.grantee in ('用户1','用户2');
spool off
spool grant_privileges_$ORACLE_SID.sql
select 'grant '||t.privilege||' on '||t.owner||'.'||t.table_name||' to '||t.grantee||decode(grantable,'YES','with grant option','')||';'
 from dba_tab_privs t
 where t.owner in ('用户1','用户2');
select 'grant '||t.privilege||' on '||t.owner||'.'||t.table_name||' to '||t.grantee||decode(grantable,'YES','with grant option','')||';'
 from dba_tab_privs t
 where t.grantee in ('用户1','用户2');
select 'grant '||t.privilege||' to '||t.grantee||';'
 from dba_sys_privs t
 where t.grantee in ('用户1','用户2');
spool off
exit
EOF
~~~





## 3、导出schema



## 4、删除用户

~~~sql
drop user xxx;
~~~







# 回滚操作

