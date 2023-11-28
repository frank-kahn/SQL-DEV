# 函数案例

## 打印1-10

~~~sql
create or replace function loop_test_01() returns void
as $$
declare
	n numeric := 0;
begin
	loop
    	n := n + 1;
    	raise notice 'n 的当前值为: %',n;
    	exit when n >= 10;
    	-- return;
  	end loop;
end;
$$ language plpgsql;
~~~



## 获取最新的序列值，并组装成更新序列值的语句

~~~sql
drop table init_sequence_table;
 
create table init_sequence_table(
   sequence_name   varchar(300) null,
	 seq_curr_val   int8 null,
	 seq_sql        varchar(300) null 
);
 
 
 
-- 创建 函数
create or replace function init_sequence()
returns void as 
$$
   declare 
	    seq_record record;
			seq_curr_val int8;
			sql1  varchar;
			seqSql varchar;
	 begin 
		  execute 'delete from init_sequence_table;';
	    for seq_record in (select relname from pg_class where relkind='S') loop 
					   sql1:='select last_value from '|| seq_record.relname;
						 execute sql1 into seq_curr_val;
						 seqSql:= 'alter sequence ' || seq_record.relname || ' restart with '||seq_curr_val;
             execute 'insert into init_sequence_table (sequence_name,seq_curr_val,seq_sql) values ('||'''' ||seq_record.relname|| ''''||','|| seq_curr_val ||','|| '''' || seqSql || ''''||');';
		  end loop;
		end;
$$
LANGUAGE plpgsql;
 
-- 调用函数
select init_sequence(); 
 
select * from init_sequence_table;
~~~

## 判断字符串是否为数字

~~~sql
create or replace function is_number(txtStr varchar) returns BOOLEAN
as
$$
BEGIN
return txtStr ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$';
end;
$$
language 'plpgsql';
~~~

## 查看表的创建时间、修改时间、vacuum、analyze时间

~~~sql
-- 创建记录DDL语句的表
CREATE TABLE pg_stat_last_operation (
    id serial PRIMARY KEY,
    object_type text,
    schema_name VARCHAR(50),
    action_name name NOT NULL,
    object_identity text,
    statime timestamp with time zone
);

-- 创建记录DDL语句的函数get_object_time_func
CREATE OR REPLACE FUNCTION get_object_time_func()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands  () 
    LOOP
        INSERT INTO public.pg_stat_last_operation (object_type, schema_name,action_name,object_identity,statime) SELECT obj.object_type, obj.schema_name, obj.command_tag,obj.object_identity,now();
    END LOOP;
END;
$$;

-- 创建触发器，在执行DDL语句时将记录写到函数中的表中
CREATE EVENT TRIGGER get_object__history_trigger ON ddl_command_end
EXECUTE PROCEDURE get_object_time_func();


CREATE FUNCTION get_object_for_drops()
        RETURNS event_trigger LANGUAGE plpgsql AS $$
DECLARE
    obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
    LOOP
    INSERT INTO public.pg_stat_last_operation (object_type, schema_name,action_name,object_identity,statime) SELECT obj.object_type, obj.schema_name,tg_tag,obj.object_identity,now();
    END LOOP;
END;
$$;


CREATE EVENT TRIGGER get_object_trigger_for_drops
   ON sql_drop
   EXECUTE PROCEDURE get_object_for_drops();
~~~

参考：

https://pgfans.cn/a/2063

https://stackoverflow.com/questions/2577168/how-to-find-table-creation-time



## 查看用户的schema权限

~~~shell
#创建函数查看用户的schema权限
CREATE OR REPLACE FUNCTION schema_privs(text)
RETURNS table(username text, schemaname name, privileges text[])
AS
$$
SELECT $1,
       c.nspname,
	   array(select privs from unnest(ARRAY[(CASE WHEN has_schema_privilege($1,c.oid,'CREATE') 
	                                              THEN 'CREATE' ELSE NULL END),
                                             (CASE WHEN has_schema_privilege($1,c.oid,'USAGE')
											      THEN 'USAGE' ELSE NULL END)])foo(privs) WHERE privs IS NOT NULL)
FROM pg_namespace c 
where has_schema_privilege($1,c.oid,'CREATE,USAGE');
$$ language sql;


#使用案例，如下test为用户名
testdb=> select schema_privs('test');
           schema_privs            
-----------------------------------
 (test,pg_catalog,{USAGE})
 (test,information_schema,{USAGE})
 (test,test,"{CREATE,USAGE}")
(3 rows)
~~~



## 获取当前库所有schema下非索引对象的记录数

~~~sql
-- 匿名块
do $$ <<get_tab_cnt>>
DECLARE
  query text;
  result text;
  cnt int;
  tbs cursor for (
					  SELECT 
					  nspname || '.' || relname as tablename
					FROM 
					  pg_class C 
					  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) 
					WHERE 
					  nspname NOT LIKE 'pg_%' 
					  AND nspname != 'information_schema' 
					  AND nspname != 'dbe_perf' 
					  AND C.relkind <> 'i' 
					  AND nspname !~ '^pg_toast' 
					  AND nspname != 'dbe_pldeveloper' 
					  and nspname != 'db4ai'
				  );
BEGIN
  for recordvar in tbs LOOP
     query :='select '||''''||recordvar.tablename||''''||','||'count(*) as cnt from '||recordvar.tablename;
     execute query into result,cnt;
	 raise notice '执行结果为：%:%',result,cnt;
  end loop;
end get_tab_cnt$$;



-- 函数
create or replace function get_tab_cnt() returns table(
  tablename text,
  cnt int8
) as $$
DECLARE
  query text;
  tbs cursor for (
					  SELECT 
					  nspname || '.' || relname as tablename
					FROM 
					  pg_class C 
					  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) 
					WHERE 
					  nspname NOT LIKE 'pg_%' 
					  AND nspname != 'information_schema' 
					  AND nspname != 'dbe_perf' 
					  AND C.relkind <> 'i' 
					  AND nspname !~ '^pg_toast' 
					  AND nspname != 'dbe_pldeveloper' 
					  and nspname != 'db4ai'
				  );
BEGIN
  for recordvar in tbs LOOP
     query :='select '||''''||recordvar.tablename||''''||','||'count(*) as cnt from '||recordvar.tablename;
  return query execute query;
  end loop;
end;
$$ language plpgsql;
~~~

## 给表添加注释如果注释不存在添加，存在不添加

~~~sql
-- 匿名块
do $$ << comment_test >>
declare
   v_schemaname pg_namespace.nspname % type := 'test'; -- 模式名
   v_tablename pg_class.relname % type :='test_t';     -- 表名
   v_comment pg_description.description % type := 'XXXXXXXXXXXXXXXXXXXX'; --表的注释内容
   flag boolean;
   v_sql text := concat('comment on table ',v_schemaname,'.',v_tablename,' is ','''',v_comment,'''');
   
begin
select case when t3.description is null or t3.description='' then true else false end
        into flag
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
left join pg_description t3 on t1.oid=t3.objoid
where 1=1
      and t1.relname = v_tablename
	  and t2.nspname = v_schemaname;

if flag
then
   raise notice 'flag=%',flag;
   execute v_sql;
else
   raise notice '表存在注释！！！';
end if;
end comment_test$$;




-- 函数
create or replace function comment_test(
v_schemaname varchar(50),
v_tablename varchar(50),
v_comment varchar(200)
) returns varchar(100)
as $$
declare
   flag boolean;
   v_sql text := concat('comment on table ',v_schemaname,'.',v_tablename,' is ','''',v_comment,'''');
begin
select case when t3.description is null or t3.description='' then true else false end
        into flag
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
left join pg_description t3 on t1.oid=t3.objoid
where 1=1
      and t1.relname = v_tablename
	  and t2.nspname = v_schemaname;
if flag
then
   execute v_sql;
   return '注释已添加！！！';
else
   return '表存在注释！！！';
end if;
end;
$$ language plpgsql;

-- 调用函数
select comment_test('test','test_t','This is a test!');
~~~



## 修改表的列名，列不存在不报错（重复执行）

~~~sql
-- 匿名块
do $$ << rename_column >>
declare
   v_schema pg_namespace.nspname % type := 'test'; -- 模式名
   v_table pg_class.relname % type :='test_t';     -- 表名
   v_col_old pg_attribute.attname % type := 'name'; --旧字段名
   v_col_new pg_attribute.attname % type := 'name1'; --新字段名
   v_flag boolean;
   v_sql text := concat('alter table ',v_schema,'.',v_table,' rename column ',v_col_old,' to ',v_col_new);
   
begin
select (case when count(*)=0 then false else true end)
        into v_flag
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
join pg_attribute t3 on t1.oid=t3.attrelid
where attnum > 0
	  and t2.nspname = v_schema
      and t1.relname = v_table
	  and t3.attname = v_col_old;

if v_flag
then
   execute v_sql;
   raise notice '字段命名成功';
else
   raise notice '字段不存在，修改失败！！！';
end if;
end rename_column$$;



-- 函数
create or replace function rename_column(
v_schema varchar(50),
v_table varchar(50),
v_col_old varchar(50),
v_col_new varchar(50)
) returns varchar(100)
as $$
declare
   v_flag boolean;
   v_sql text := concat('alter table ',v_schema,'.',v_table,' rename column ',v_col_old,' to ',v_col_new);
begin
select (case when count(*)=0 then false else true end)
        into v_flag
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
join pg_attribute t3 on t1.oid=t3.attrelid
where attnum > 0
	  and t2.nspname = v_schema
      and t1.relname = v_table
	  and t3.attname = v_col_old;
if v_flag
then
   execute v_sql;
   return '字段命名成功';
else
   return '字段不存在，修改失败！！！';
end if;
end;
$$ language plpgsql;
~~~



测试

~~~sql
create table test_t (id int,name varchar(100));

select t2.nspname,t1.relname,t3.attname
from pg_class t1
join pg_namespace t2 on t1.relnamespace=t2.oid
join pg_attribute t3 on t1.oid=t3.attrelid
where attnum > 0
	  and t2.nspname = 'test'
      and t1.relname = 'test_t';
      
 nspname | relname | attname 
---------+---------+---------
 test    | test_t  | id
 test    | test_t  | name
(2 rows)

postgres=# select rename_column('test','test_t','name','name1');
 rename_column 
---------------
 字段命名成功
(1 row)

 nspname | relname | attname 
---------+---------+---------
 test    | test_t  | id
 test    | test_t  | name1
(2 rows)

postgres=# select rename_column('test','test_t','name','name1');
       rename_column        
----------------------------
 字段不存在，修改失败！！！
(1 row)
~~~

