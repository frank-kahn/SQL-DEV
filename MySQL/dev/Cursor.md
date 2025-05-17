# MySQL游标

## 语法格式

游标（Cursor）是在MySQL中用于遍历结果集的一种机制。以下是一个简单的MySQL游标的使用案例，该案例从一个表中选择数据，并通过游标逐行处理结果集：

~~~sql
-- 创建一个存储过程，使用游标从表中选择数据
DELIMITER //

CREATE PROCEDURE ProcessData()
BEGIN
  -- 声明变量用于存储结果集的字段值
  DECLARE col1_value INT;
  DECLARE col2_value VARCHAR(255);

  -- 声明游标
  DECLARE data_cursor CURSOR FOR
    SELECT column1, column2
    FROM your_table; -- 替换为实际的表名

  -- 声明 continue handler 以处理结果集结束的情况
  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET done = TRUE;

  -- 打开游标
  OPEN data_cursor;

  -- 初始化 done 变量
  SET done = FALSE;

  -- 使用 repeat 循环，逐行处理结果集
  data_loop: REPEAT
    -- 从游标中读取数据到变量
    FETCH data_cursor INTO col1_value, col2_value;

    -- 判断是否到达结果集末尾
    IF done THEN
      LEAVE data_loop;
    END IF;

    -- 在这里可以进行具体的数据处理操作，例如打印或使用变量的值
    SELECT CONCAT('Column1: ', col1_value, ', Column2: ', col2_value) AS Result;

  UNTIL done END REPEAT;

  -- 关闭游标
  CLOSE data_cursor;

END //

DELIMITER ;
~~~

## 游标示例

### 遍历游标批量update Join

创建测试数据

~~~sql
drop table if exists user_tmp,user;
create table user_tmp (id int,name varchar(100));
create table user (id int,name varchar(100));

insert into user_tmp values (1,'zhangsan'),(2,'lisi'),(3,'wangwu'),(4,'zhaoliu');
insert into user values (null,'zhangsan'),(7,'zhengqi'),(null,'lisi'),(3,'wangwu');
~~~

如上根据name字段匹配user_tmp中的id，替换user表中id为null的记录

update写法：

~~~sql
update user t1 
join user_tmp t2 on t1.name=t2.name 
set t1.id = t2.id
where exists (
  select 1 from (
    select t.name from user t join user_tmp using (name) where t.id is null limit 10000
  ) subquery
  where subquery.name=t1.name
);
~~~

使用游标

~~~sql
DELIMITER $$
CREATE PROCEDURE update_user_ids()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE offset INT DEFAULT 0;
    DECLARE tmp_name varchar(100);
    DECLARE tmp_id INT8;
    -- 创建一个游标，用于遍历需要更新的记录
    DECLARE cur CURSOR FOR
    SELECT u.name, ut.id
    FROM user u
    JOIN user_tmp ut ON u.name = ut.name
    WHERE u.id IS NULL;
    -- 声明退出处理
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;
    -- 循环遍历游标中的记录
    read_loop: LOOP
        FETCH cur INTO tmp_name, tmp_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- 更新user表中的id
        UPDATE user set id = tmp_id where id is null and name = tmp_name;
    END LOOP;
    CLOSE cur;
END$$
DELIMITER ;
~~~

