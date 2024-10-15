# 触发器案例

## PostgreSQL利用事件触发器记录表的创建和删除时间

~~~sql
在postgresql中有一种触发器，叫做事件触发器，我们可以通过这个来记录表的创建和删除时间等。

1.创建一个事件触发器，记录所有的drop table操作用于事后审计

记录删除的事件触发器，利用到了一个系统函数pg_event_trigger_dropped_objects()

1)创建表，用于记录drop操作
create table drop_audit(
classid     	oid,
objid	   		oid,
objsubid	 	int,
object_type  	text,
schema_name  	text,
object_name  	text,
object_identity  text,
ddl_tag 	 	text,
op_time 		timestamp
);
2)创建触发器函数
create or replace function event_trigger_drop_function()
	returns event_trigger
	language plpgsql
AS $$
	declare
		obj record;
	begin
		insert into drop_audit
		select classid,objid,objsubid,object_type,schema_name,
		object_name,object_identity,tg_tag,now()
		from pg_event_trigger_dropped_objects();
	end;
$$;

3)创建触发器
create event trigger drop_event_trigger on sql_drop  when tag in ('drop table')
execute procedure event_trigger_drop_function();
----------------------------------------------------------
2.接下来创建一个触发器，用户记录create table操作
记录create table的触发器用到了pg_event_trigger_ddl_commands()函数
1)为了方便，还是直接使用上面的drop_audit这个表
2)创建触发器函数
create or replace function event_trigger_ddl_commands_function()
	returns event_trigger
	language plpgsql
AS $$
	declare
		obj record;
	begin
		insert into drop_audit
		select classid,objid,objsubid,object_type,schema_name,
		'',object_identity,tg_tag,now()
		from pg_event_trigger_ddl_commands();
	end;
$$;
3)创建触发器
create event trigger ddl_event_trigger on ddl_command_end  when tag in ('create table')
execute procedure event_trigger_ddl_commands_function();
4)测试
同样，create table的操作也会记录进去

---------------------------------------------------------------------------------
3.记录alter table操作日志
1)创建触发器
create event trigger ddl_event_trigger_alter on ddl_command_end  when tag in ('alter table')
execute procedure event_trigger_ddl_commands_function();
~~~



## 带when条件的触发器

1、创建 `orders` 表

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    amount NUMERIC NOT NULL,
    customer_name VARCHAR(100)
);
```

2、创建 `audit_log` 表

```sql
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    order_id INT,
    action VARCHAR(50),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

3、创建触发器函数

接下来，我们需要创建一个触发器函数，该函数将在满足条件时被调用。

```sql
CREATE OR REPLACE FUNCTION log_high_value_order()
RETURNS TRIGGER AS $$
BEGIN
    -- 检查订单金额是否超过 1000
    IF NEW.amount > 1000 THEN
        -- 插入审计日志
        INSERT INTO audit_log (order_id, action) 
        VALUES (NEW.id, 'High Value Order');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

4、创建带有条件的触发器

现在，我们可以创建一个触发器，在插入 `orders` 表时调用这个函数，并为其添加 `WHEN` 条件。

```sql
CREATE TRIGGER high_value_order_trigger
AFTER INSERT ON orders
FOR EACH ROW
WHEN (NEW.amount > 1000)
EXECUTE FUNCTION log_high_value_order();
```

5、插入数据并验证触发器

现在，我们可以插入一些订单，看看触发器是否按预期工作。

```sql
-- 插入一条金额超过1000的订单
INSERT INTO orders (order_date, amount, customer_name) VALUES ('2024-10-15', 1500, 'Alice');

-- 插入一条金额未超过1000的订单
INSERT INTO orders (order_date, amount, customer_name) VALUES ('2024-10-15', 800, 'Bob');
```

6、查询审计日志

最后，您可以查询 `audit_log` 表，查看是否记录了高价值订单的日志。

```sql
SELECT * FROM audit_log;
```

