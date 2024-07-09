# 游标案例

## 隐式游标

~~~sql
/* 测试表结构 */
create table role (role_id int8 primary key,role_name varchar,scope varchar(100),status varchar(100)); 
create table permission (permission_id int8 primary key,pr_uid varchar(100),app_name varchar(100)); 
create table acl(role_id int8 references role(role_id) on delete cascade on update cascade ,
                  permission_id int8 references permission(permission_id) on delete cascade on update cascade);




/* 检查权限点是否需要给角色授 */ 
DO $$ << check_permission >>
DECLARE 
     v_scope ROLE.SCOPE % TYPE := 'tmc'; --输入scope值
     v_pr_uid permission.pr_uid % TYPE := 'read1'; --输入权限点的pr_uid 
     v_app_name permission.app_name % TYPE := 'tmc'; --输入appname 
     v_count int8; 
BEGIN 
      SELECT COUNT ( * ) INTO v_count FROM ( 
	  SELECT rt.role_id, pt.permission_id FROM ROLE rt, permission pt
	  WHERE rt.SCOPE = 'tmc'
	        AND rt.status = '1'
			AND pt.pr_uid = 'read1' --commonQuery read
			AND pt.app_name = 'tmc' --tmc_admin/tmc
			AND NOT EXISTS ( SELECT 1 FROM acl act 
			                  WHERE act.role_id = rt.role_id
							  AND act.permission_id = pt.permission_id ) 
	    ) T;
IF v_count > 0
THEN
raise notice'需要为所有角色授予对应的权限点！！！';
ELSE
raise notice'所有的角色已经拥有该权限点';
END IF; 
END check_permission$$;





/* 更新aclentry表为角色授予权限点 */ 
do $$ <<update_acl>>
declare v_scope role.scope%type :='tmc'; --输入scope值
  v_pr_uid permission.pr_uid%type :='read1'; --输入权限点的pr_uid
  v_app_name permission.app_name%type :='tmc'; --输入appname
  v_cnt int8;
cur CURSOR FOR (SELECT rt.role_id, pt.permission_id
                 FROM role rt, permission pt
				 WHERE rt.SCOPE = v_scope 
				 AND rt.status = '1'
				 AND pt.pr_uid = v_pr_uid --commonQuery read
				 AND pt.app_name = v_app_name --tmc_admin/tmc
				 AND NOT EXISTS ( SELECT 1 FROM acl act 
				                   WHERE act.role_id = rt.role_id
								   AND act.permission_id = pt.permission_id));

begin
for recordvar in cur loop
SELECT COUNT(*) INTO v_cnt FROM acl
WHERE acl.role_id = recordvar.role_id
AND acl.permission_id = recordvar.permission_id;
IF v_cnt = 0
THEN
INSERT INTO acl (role_id ,permission_id) 
VALUES (recordvar.role_id ,recordvar.permission_id);
END IF;
end loop;

IF v_cnt=0
then
raise notice '为所有的角色授权成功，授权的权限点为：%',v_pr_uid;
else
raise notice '所有的角色已经拥有该权限点';
end if;
end update_acl$$; 
~~~

## 循环遍历数组元素

```sql
do $$
declare i int;
begin
 foreach i in array array[12,1,2,3] loop
 raise notice 'i=%',i;
 end loop;
end $$;
```

