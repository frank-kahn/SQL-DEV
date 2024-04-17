# 限制表的总行数

创建测试数据

```sql
drop table if exists test_t;
create table test_t (id int,name varchar(100));
insert into test_t values
(1,'zhangsan'),
(2,'lisi'),
(3,'wangwu'),
(4,'zhaoliu'),
(5,'qiqi'),
(6,'zhuba');
```

创建触发器

```sql
drop trigger if exists limit_table_rows;

delimiter //
create trigger limit_table_rows
before insert on test_t
for each row
begin
  declare row_count int;
  select count(*) into row_count from test_t;
  if row_count >5 then
    signal sqlstate '45000' set message_text = 'Exceeded maximun row count';
  end if;
end;
//
delimiter ;
```

说明：

- 该触发器的逻辑是先查询表的记录数，如果记录数大于如上第10行限制，则针对该表的insert操作报错
- 基于以上逻辑限制不住建表之后首次插入数据的条数，因为此时表行数为0，满足条件

```sql
mysql> select count(*) from test_t;
+----------+
| count(*) |
+----------+
|        7 |
+----------+
1 row in set (0.00 sec)

mysql> insert into test_t values (1,'zhangsan');
ERROR 1644 (45000): Exceeded maximun row count
mysql>
```

