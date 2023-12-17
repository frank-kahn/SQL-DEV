# procedure

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

