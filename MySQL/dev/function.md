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

