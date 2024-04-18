# mysql数据库实现nextval函数

**1、新建序列表**

~~~sql
drop table if exists sequence;
create table sequence (       
seq_name    VARCHAR(50)  NOT NULL,                    -- 序列名称
current_val     INT         NOT NULL,                 -- 当前值
increment_val   INT         NOT NULL    DEFAULT 1,    -- 步长(跨度)       
PRIMARY KEY (seq_name)) DEFAULT CHARACTER set utf8;
~~~

**2、新增一个序列**

~~~shell
INSERT INTO sequence VALUES ('seq_test', '0', '1');
~~~

**3、创建currval函数，用于获取序列当前值**

~~~shell
delimiter //
create function currval(v_seq_name VARCHAR(50))   
returns integer(11) 
begin
 declare value integer;
 set value = 0;
 select current_val into value from sequence where seq_name = v_seq_name;
   return value;
end;
//
delimiter ;
~~~

**4、查询当前值**

~~~shell
select currval('seq_test');
~~~

**5、创建nextval函数，用于获取序列下一个值**

~~~shell
delimiter //
create function nextval (v_seq_name VARCHAR(50)) returns integer(11) 
begin
    update sequence set current_val = current_val + increment_val  where seq_name = v_seq_name;
    return currval(v_seq_name);
end;
//
delimiter ;
~~~

**6.查询下一个值**

~~~shell
select nextval('seq_test');
~~~

# 创建限制表行数的触发器

创建测试表

~~~sql
drop table if exists test_t;
create table test_t (id int,name varchar(100));
insert into test_t values
(1,'zhangsan'),
(2,'lisi'),
(3,'wangwu'),
(4,'zhaoliu'),
(5,'qiqi'),
(6,'zhuba');
~~~



创建函数

```sql
delimiter //
create function create_trigger(tablename varchar(100),rowlimit int) returns text
begin
  declare trigger_name varchar(100);
  set trigger_name = concat('limit_',tablename);
  set @sql = concat('create trigger ',trigger_name,' before insert on ',tablename,' for each row begin declare row_count int;select count(*) into row_count from ',tablename,';if row_count >',rowlimit,' then signal sqlstate ''45000'' set message_text = ''Exceeded maximun row count'';end if;end;');
  -- prepare stmt from @sql;
  -- execute stmt;
  -- deallocate prepare stmt;
  return @sql;
  end;
//
delimiter ;

-- 执行函数
select create_trigger('test_t',5);
```

<font color='red'>动态SQL不能在函数中创建，所以此处只是把创建触发器的创建命令返回了</font>

~~~sql
ERROR 1336 (0A000): Dynamic SQL is not allowed in stored function or trigger
~~~

