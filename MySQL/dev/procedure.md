# procedure

## MySQL游标

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



## 自动添加新的分区

~~~sql
CREATE TABLE new_table (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  date DATE
) ENGINE=InnoDB;


ALTER TABLE new_table
PARTITION BY RANGE (YEAR(date))
(
  PARTITION p0 VALUES LESS THAN (2010),
  PARTITION p1 VALUES LESS THAN (2015),
  PARTITION p2 VALUES LESS THAN (2020),
  PARTITION p3 VALUES LESS THAN MAXVALUE
);


-- 创建一个存储过程来自动添加新的分区
DELIMITER //
CREATE PROCEDURE add_partition()
BEGIN
  DECLARE max_year INT;
  DECLARE current_year INT DEFAULT YEAR(CURDATE());
  SELECT MAX(YEAR(date)) INTO max_year FROM old_table;
  IF max_year < current_year THEN
    SET max_year = current_year;
  END IF;
  SET @sql = CONCAT('ALTER TABLE old_table ADD PARTITION (PARTITION p', max_year + 1, ' VALUES LESS THAN (', max_year + 1, '))');
  PREPARE stmt FROM @sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
~~~

## 动态备份表

~~~sql
-- 创建测试表
create table test_t(id int,name varchar(20)) ;
insert into test_t values(1,'情到');
insert into test_t values(2,'深处');
insert into test_t values(3,'人孤独');


drop procedure if exists backuptable;

DELIMITER //
create procedure backuptable (in tablename varchar(41))
begin
  declare dateString varchar(23);
  select date_format(current_timestamp(6),"_%Y%m%d_%H%i%S_%f") into dateString;
  set @sqlString = concat('create table if not exists ',tablename,dateString,' as select * from ',tablename);
  select @sqlString;
  prepare stmt from @sqlString;
  execute stmt;
  deallocate prepare stmt;
  END //
DELIMITER ;



 -- 调用方式1
call backuptable('test_t');

-- 调用方式2
set @tablename := 'test_t';
call backuptable(@tablename);
~~~



## 获取非系统库下每个表的行数（报错待研究）

~~~sql
DELIMITER //
CREATE PROCEDURE GetRowCounts()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE current_db VARCHAR(255);
  DECLARE current_table VARCHAR(255);
  DECLARE total_rows INT;
  -- Cursor to iterate through databases and tables
  DECLARE db_cursor CURSOR FOR
    SELECT schema_name
    FROM information_schema.schemata
    WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');
  -- Declare continue handler to exit loop
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN db_cursor;
  read_loop: LOOP
    -- Fetch the next database
    FETCH db_cursor INTO current_db;
    IF done THEN
      LEAVE read_loop;
    END IF;
    -- Cursor to iterate through tables in the current database
    DECLARE table_cursor CURSOR FOR
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = current_db;
    OPEN table_cursor;
    table_loop: LOOP
      -- Fetch the next table in the current database
      FETCH table_cursor INTO current_table;
      IF done THEN
        LEAVE table_loop;
      END IF;
      -- Dynamic SQL to get the row count for the current table
      SET @sql = CONCAT('SELECT COUNT(*) FROM `', current_db, '`.`', current_table, '`');
      PREPARE stmt FROM @sql;
      EXECUTE stmt INTO total_rows;
      DEALLOCATE PREPARE stmt;
      -- Display or use the row count as needed
      SELECT CONCAT('Database: ', current_db, ', Table: ', current_table, ', Row Count: ', total_rows) AS Result;
    END LOOP;
    CLOSE table_cursor;
  END LOOP;
  CLOSE db_cursor;
END //
DELIMITER ;
~~~



可用待研究（union all的方式）

~~~sql
drop PROCEDURE if exists GetAllTableCounts;

DELIMITER //
CREATE PROCEDURE GetAllTableCounts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE aDatabase CHAR(64);
    DECLARE aTable CHAR(64);
    DECLARE dateString VARCHAR(23);
    DECLARE cur1 CURSOR FOR SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');
    DECLARE cur2 CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = aDatabase;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    set @sqlString = 'select ''数据库名'' as dbname,''表名'' as tablename,''数量'' as count ';
    OPEN cur1;

    read_loop: LOOP
        FETCH cur1 INTO aDatabase;
        IF done THEN
            LEAVE read_loop;
        END IF;

        OPEN cur2;
        table_loop: LOOP
            FETCH cur2 INTO aTable;
            IF done THEN
                LEAVE table_loop;
            END IF;
            
            set @sqlString = CONCAT(@sqlString ,' union all select ''',aDatabase,''' as dbname, ''',aTable,''' as tablename, count(*) from ',aDatabase,'.',aTable);
            
        END LOOP table_loop;

        CLOSE cur2;
        SET done = FALSE;
    END LOOP read_loop;
    
    CLOSE cur1;
    select @sqlString;
    
    PREPARE stmt FROM @sqlString;
    execute stmt;
    DEALLOCATE PREPARE stmt;
    
END //
DELIMITER ;


-- 调用方式1
call GetAllTableCounts();


-- 结果
+---------+--------------------+-------+
| dbname  | tablename          | count |
+---------+--------------------+-------+
|         | 表                |   |
| testdb1 | get_row_counts_tmp | 7     |
| testdb1 | test_t1            | 21    |
| testdb1 | test_t2            | 98    |
| testdb1 | test_t3            | 49    |
| testdb2 | test_t1            | 74    |
| testdb2 | test_t2            | 62    |
| testdb2 | test_t3            | 84    |
+---------+--------------------+-------+
8 rows in set (0.00 sec)
~~~



## 获取非系统库下每个表的行数

### 方法一：MySQL存过查数据库表数据量-直接输出

~~~sql
-- 创建存过
drop PROCEDURE if exists GetRowCounts;

DELIMITER //
CREATE PROCEDURE GetRowCounts(OUT total_rows tinyint)
BEGIN
  DECLARE resultString VARCHAR(16383);
  DECLARE done INT DEFAULT FALSE;
  DECLARE current_db VARCHAR(255);
  DECLARE current_table VARCHAR(255);
  DECLARE db_cursor CURSOR FOR
    SELECT schema_name
      FROM information_schema.schemata
     WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');
  DECLARE table_cursor CURSOR FOR
      SELECT table_name
      FROM information_schema.tables
      WHERE binary table_schema = binary current_db;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN db_cursor;
  read_loop: LOOP
    FETCH db_cursor INTO current_db;
    IF done THEN
      LEAVE read_loop;
    END IF;
    OPEN table_cursor;
    table_loop: LOOP
      FETCH table_cursor INTO current_table;
      IF done THEN
        LEAVE table_loop;
      END IF;
      set @total_rows = 0;
      SET @sql = CONCAT('SELECT COUNT(*) INTO @total_rows FROM `', current_db, '`.`', current_table, '`');
      PREPARE stmt FROM @sql;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
      set resultString = CONCAT(IFNULL(resultString,''), 'DB: ', IFNULL(current_db,'null'), ', TB: ', IFNULL(current_table,'null'), ', RW : ', IFNULL(@total_rows,'NULL'), ' ; ',char(10));
    END LOOP;
    CLOSE table_cursor;
    SET done = FALSE;
  END LOOP;
  CLOSE db_cursor;
  select resultString;
END //
DELIMITER ;


-- 调用方法
set @total_rows = 0;
call GetRowCounts(@total_rows);


-- 结果示例
DB: testdb1, TB: test_t1, RW : 21 ; 
DB: testdb1, TB: test_t2, RW : 98 ; 
DB: testdb1, TB: test_t3, RW : 49 ; 
DB: testdb2, TB: test_t1, RW : 74 ; 
DB: testdb2, TB: test_t2, RW : 62 ; 
DB: testdb2, TB: test_t3, RW : 84 ; 
~~~

### 方法二：MySQL存过查数据库表数据量-输出到临时表

~~~sql
-- 创建临时表
DROP TABLE IF EXISTS get_row_counts_tmp;
CREATE TABLE `get_row_counts_tmp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dbname` varchar(100) NOT NULL COMMENT '数据库名',
  `tablename` varchar(255) DEFAULT NULL COMMENT '表名',
  `total_rows` int(11) DEFAULT NULL COMMENT '表数量',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;




-- 创建存过GetRowCountsToTable()
drop PROCEDURE if exists GetRowCountsToTable;
DELIMITER //
CREATE PROCEDURE GetRowCountsToTable(OUT total_rows tinyint)
BEGIN
  DECLARE resultString VARCHAR(16383);
  DECLARE done INT DEFAULT FALSE;
  DECLARE current_db VARCHAR(255);
  DECLARE current_table VARCHAR(255);
  DECLARE db_cursor CURSOR FOR
    SELECT schema_name
      FROM information_schema.schemata
     WHERE schema_name NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys');
  DECLARE table_cursor CURSOR FOR
      SELECT table_name
      FROM information_schema.tables
      WHERE binary table_schema = binary current_db;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  /* 清空临时表数据 begin */
  set @v_sql2 = 'truncate table get_row_counts_tmp';
  PREPARE stmt3 FROM @v_sql2;
  EXECUTE stmt3;
  DEALLOCATE PREPARE stmt3;
  /* 清空临时表数据 end */
  
  OPEN db_cursor;
  read_loop: LOOP
    FETCH db_cursor INTO current_db;
    IF done THEN
      LEAVE read_loop;
    END IF;
    OPEN table_cursor;
    table_loop: LOOP
      FETCH table_cursor INTO current_table;
      IF done THEN
        LEAVE table_loop;
      END IF;
      set @total_rows = 0;
      SET @sql = CONCAT('SELECT COUNT(*) INTO @total_rows FROM `', current_db, '`.`', current_table, '`');
      PREPARE stmt FROM @sql;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
      set @v_sql = CONCAT('insert into get_row_counts_tmp (dbname,tablename,total_rows) select ''', current_db, ''' as dbname, ''', current_table, ''' as tablename, ', @total_rows, ' as total_rows');
      PREPARE stmt2 FROM @v_sql;
      EXECUTE stmt2;
      DEALLOCATE PREPARE stmt2;
      -- set resultString = CONCAT(IFNULL(resultString,''), 'DB: ', IFNULL(current_db,'null'), ', TB: ', IFNULL(current_table,'null'), ', RW : ', IFNULL(@total_rows,'NULL'), ' ; ',char(10));
    END LOOP;
    CLOSE table_cursor;
    SET done = FALSE;
  END LOOP;
  CLOSE db_cursor;
  -- select resultString;
END //
DELIMITER ;


-- 调用
set @total_rows = 0;
call GetRowCountsToTable(@total_rows);


-- 查询临时表结果
mysql> select * from get_row_counts_tmp where tablename <> 'get_row_counts_tmp';
+----+---------+-----------+------------+
| id | dbname  | tablename | total_rows |
+----+---------+-----------+------------+
|  2 | testdb1 | test_t1   |         21 |
|  3 | testdb1 | test_t2   |         98 |
|  4 | testdb1 | test_t3   |         49 |
|  5 | testdb2 | test_t1   |         74 |
|  6 | testdb2 | test_t2   |         62 |
|  7 | testdb2 | test_t3   |         84 |
+----+---------+-----------+------------+
6 rows in set (0.00 sec)
~~~



