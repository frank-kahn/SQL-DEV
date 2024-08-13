# MySQL分区表详解

## MySQL分区表规则

1、MySQL 在第一次打开分区表的时候，需要访问所有的分区；

2、在 server 层，认为这是同一张表，因此所有分区共用同一个 MDL 锁；

3、在引擎层，认为这是不同的表，因此 MDL 锁之后的执行过程，会根据分区表规则，只访问必要的分区。

这里有两个问题需要注意：

1、分区并不是越细越好。实际上，单表或者单分区的数据一千万行，只要没有特别大的索引，对于现在的硬件能力来说都已经是小表了。

2、分区也不要提前预留太多，在使用之前预先创建即可。比如，如果是按月分区，每年年底时再把下一年度的 12 个新分区创建上即可。对于没有数据的历史分区，要及时的drop 掉。

至于分区表的其他问题，比如查询需要跨多个分区取数据，查询性能就会比较慢，基本上就不是分区表本身的问题，而是数据量的问题或者说是使用方式的问题了。

## 分区表设计方案

### 范围分区

```sql
CREATE TABLE employees (
   id INT NOT NULL,
   fname VARCHAR(30),
   lname VARCHAR(30),
   hired DATE NOT NULL DEFAULT '1970-01-01',
   separated DATE NOT NULL DEFAULT '9999-12-31',
   job_code INT NOT NULL,
   store_id INT NOT NULL
)
PARTITION BY RANGE (store_id) (
   PARTITION p0 VALUES LESS THAN (6),
   PARTITION p1 VALUES LESS THAN (11),
   PARTITION p2 VALUES LESS THAN (16),
   PARTITION p3 VALUES LESS THAN MAXVALUE
);
```

注意：

- RANGE分区的返回值必须为整数。
- MAXVALUE分区是非必需的

**RANGE COLUMNS分区**

RANGE COLUMNS是RANGE分区的一种特殊类型，它与RANGE分区的区别如下：

- RANGE COLUMNS不接受表达式，只能是列名。而RANGE分区则要求分区的对象是整数。
- RANGE COLUMNS允许多个列，在底层实现上，它比较的是元祖(多个列值组成的列表)，而RANGE比较的是标量，即数值的大小。
- RANGE COLUMNS不限于整数对象，date，datetime，string都可作为分区列。

```sql
CREATE TABLE rcx (
   a INT,
   b INT,
   c CHAR(3),
   d INT
)
PARTITION BY RANGE COLUMNS(a,d,c) (
   PARTITION p0 VALUES LESS THAN (5,10,'ggg'),
   PARTITION p1 VALUES LESS THAN (10,20,'mmm'),
   PARTITION p2 VALUES LESS THAN (15,30,'sss'),
   PARTITION p3 VALUES LESS THAN (MAXVALUE,MAXVALUE,MAXVALUE)
);
```

同RANGE分区类似，它的区间范围必须是递增的，有时候，列涉及的太多，不好判断区间的大小，可采用下面的方式进行判断：

```sql
mysql> SELECT (5,10) < (5,12), (5,11) < (5,12), (5,12) < (5,12);
+-----------------+-----------------+-----------------+
| (5,10) < (5,12) | (5,11) < (5,12) | (5,12) < (5,12) |
+-----------------+-----------------+-----------------+
|               1 |               1 |               0 |
+-----------------+-----------------+-----------------+
1 row in set (0.00 sec)
```



### 列表分区

列表分区和范围分区类似，主要区别是list partition的分区范围是预先定义好的一系列值，而不是连续的范围。列表分区采用partition by list和values in子句定义。

示例，创建一张员工表按照employee_id进行列表分区：

```sql
CREATE TABLE employees (
  employee_id int(6) primary key,
  first_name varchar(20),
  last_name varchar(25),
  email varchar(25),
  phone_number varchar(20),
  hire_date datetime, 
  job_id varchar(10),
  salary int(8),
  commission_pct decimal(2,2),
  manager_id decimal(6,0),
  department_id int(4)
)
PARTITION BY LIST(employee_id) (
    PARTITION p0 VALUES IN (101,103,105,107,109),
    PARTITION p1 VALUES IN (102,104,106,108,110)
);

INSERT INTO employees VALUES ('100', 'Steven', 'King', 'SKING', '515.123.4567', '1987-06-17 00:00:00', 'AD_PRES', '24000.00', null, null, '90');
INSERT INTO employees VALUES ('101', 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', '1989-09-21 00:00:00', 'AD_VP', '17000.00', null, '100', '90');
INSERT INTO employees VALUES ('102', 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', '1993-01-13 00:00:00', 'AD_VP', '17000.00', null, '100', '90');
INSERT INTO employees VALUES ('103', 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', '1990-01-03 00:00:00', 'IT_PROG', '9000.00', null, '102', '60');
INSERT INTO employees VALUES ('104', 'Bruce', 'Ernst', 'BERNST', '590.423.4568', '1991-05-21 00:00:00', 'IT_PROG', '6000.00', null, '103', '60');
INSERT INTO employees VALUES ('105', 'David', 'Austin', 'DAUSTIN', '590.423.4569', '1997-06-25 00:00:00', 'IT_PROG', '4800.00', null, '103', '60');
INSERT INTO employees VALUES ('106', 'Valli', 'Pataballa', 'VPATABAL', '590.423.4560', '1998-02-05 00:00:00', 'IT_PROG', '4800.00', null, '103', '60');
INSERT INTO employees VALUES ('107', 'Diana', 'Lorentz', 'DLORENTZ', '590.423.5567', '1999-02-07 00:00:00', 'IT_PROG', '4200.00', null, '103', '60');
INSERT INTO employees VALUES ('108', 'Nancy', 'Greenberg', 'NGREENBE', '515.124.4569', '1994-08-17 00:00:00', 'FI_MGR', '12000.00', null, '101', '100');
INSERT INTO employees VALUES ('109', 'Daniel', 'Faviet', 'DFAVIET', '515.124.4169', '1994-08-16 00:00:00', 'FI_ACCOUNT', '9000.00', null, '108', '230');
INSERT INTO employees VALUES ('110', 'John', 'Chen', 'JCHEN', '515.124.4 269', '1997-09-28 00:00:00', 'FI_ACCOUNT', '8200.00', null, '108', '100');
```

查询分区数据

```sql
select * from employees partition(p0);
select * from employees partition(p1);
select * from employees partition(p0,p1);
```

和range分区一样，可以使用alter table … add/drop partition新增/删除分区：

```sql
ALTER TABLE employees ADD PARTITION(PARTITION p2 VALUES IN (111,112,113,114,115));
ALTER TABLE employees DROP PARTITION p2;
```

LIST COLUMNS分区表，分区字段支持使用CHAR VARCHAR DATE等数据类型。普通的LIST分区表分区字段必须是INT类型。

```sql
drop table if exists employees;
CREATE TABLE employees (
    employee_id int(6),
    first_name varchar(20),
    last_name varchar(25),
    email varchar(25),
    phone_number varchar(20),
    hire_date datetime,
    job_id varchar(10),
    salary int(8),
    commission_pct decimal(2,2),
    manager_id decimal(6,0),
    department_id int(4)
)
PARTITION BY LIST COLUMNS(last_name) (
    PARTITION p0 VALUES IN ('King','Grant'),
    PARTITION p1 VALUES IN ('Scott','Jim')
);
```

### 哈希分区

和RANGE，LIST分区不同的是，HASH分区无需定义分区的条件。只需要指明分区数即可。

```sql
drop table if exists employees;
CREATE TABLE employees (
   id INT NOT NULL,
   fname VARCHAR(30),
   lname VARCHAR(30),
   hired DATE NOT NULL DEFAULT '1970-01-01',
   separated DATE NOT NULL DEFAULT '9999-12-31',
   job_code INT,
   store_id INT
)
PARTITION BY HASH(store_id) PARTITIONS 4;
```

注意：

- HASH分区可以不用指定PARTITIONS子句，如上文中的PARTITIONS 4，则默认分区数为4。
- 不允许只写PARTITIONS，而不指定分区数。
- 同RANGE分区和LIST分区一样，PARTITION BY HASH (expr)子句中的expr返回的必须是整数值。
- HASH分区的底层实现其实是基于MOD函数。譬如，对于下表

```sql
CREATE TABLE t1 (col1 INT, col2 CHAR(5), col3 DATE)
PARTITION BY HASH( YEAR(col3) ) PARTITIONS 4;
-- 如果你要插入一个col3为“2005-09-15”的记录，则分区的选择是根据以下值决定的：
MOD(YEAR('2005-09-01'),4)= MOD(2005,4)=1
```

**LINEAR HASH分区**

LINEAR HASH分区是HASH分区的一种特殊类型，与HASH分区是基于MOD函数不同的是，它基于的是另外一种算法。

格式如下：

```sql
drop table if exists employees;
CREATE TABLE employees (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT,
    store_id INT
)
PARTITION BY LINEAR HASH(YEAR(hired)) PARTITIONS 4;
```

说明：

- 它的优点是在数据量大的场景，譬如TB级，增加、删除、合并和拆分分区会更快，缺点是，相对于HASH分区，它数据分布不均匀的概率更大。
- 具体算法，可参考MySQL的官方文档

### key分区

KEY分区其实跟HASH分区差不多，不同点如下：

- KEY分区允许多列，而HASH分区只允许一列。
- 如果在有主键或者唯一键的情况下，key中分区列可不指定，默认为主键或者唯一键，如果没有，则必须显性指定列。
- KEY分区对象必须为列，而不能是基于列的表达式。
- KEY分区和HASH分区的算法不一样，PARTITION BY HASH (expr)，MOD取值的对象是expr返回的值，而PARTITION BY KEY (column_list)，基于的是列的MD5值。

```sql
CREATE TABLE k1 (
   id INT NOT NULL PRIMARY KEY,
   name VARCHAR(20)
)
PARTITION BY KEY() PARTITIONS 2;
-- 在没有主键或者唯一键的情况下，格式如下：
CREATE TABLE tm1 (
s1 CHAR(32)
)
PARTITION BY KEY(s1) PARTITIONS 10;
```

**LINEAR KEY分区**

同LINEAR HASH分区类似。

格式如下：

```sql
CREATE TABLE tk (
   col1 INT NOT NULL,
   col2 CHAR(5),
   col3 DATE
)
PARTITION BY LINEAR KEY (col1) PARTITIONS 3;
```



## 普通表转换分区表

测试数据

~~~sql
-- 非分区表如下：
create table test (
id bigint(20) not null auto_increment comment '主键id',
name varchar(200) default null comment '名字',
create_time datetime not null default current_timestamp comment '创建时间',
address varchar(200) default null comment '地址',
primary key (create_time,id),
key idx_name (name),
key idx_id (id)
) engine=innodb auto_increment=2293142 default charset=utf8mb4 comment='测试表';
~~~

### 方法1（alter表）

1、因为分区表要求分区字段 CREATE_TIME 必须不为空，所以首先查看表中是否存在空值

~~~sql
select count(*) from test where create_time is null or '';
~~~

2、如果分区字段 CREATE_TIME 存在空值，必须修改为不为空的值或者删除空值数据（由业务开发决定）

~~~sql
update test set create_time='2022-08-07 11:11:11' where 1=1;
或者
delete from test where create_time is null or '';
~~~

3、修改分区字段 CREATE_TIME 默认值不为空；

~~~sql
alter table test modify create_time datetime not null comment '创建时间';
~~~

4、修改主键（主键删除和新增必须放一起，否则阻塞dml）；

~~~sql
alter table test drop primary key,add primary key (create_time,id);
~~~

5、重组分区，锁全表（数据量越大，执行越久）；

~~~sql
alter table test partition by range columns (create_time)(
partition p202301 values less than ('2023-02-01'),
partition p202302 values less than ('2023-03-01'),
partition p202303 values less than ('2023-04-01'),
partition p202304 values less than ('2023-05-01'),
partition p202305 values less than ('2023-06-01'),
partition p202306 values less than ('2023-07-01'),
partition p202307 values less than ('2023-08-01'),
partition p202308 values less than ('2023-09-01'),
partition p202309 values less than ('2023-10-01'),
partition p202310 values less than ('2023-11-01'),
partition p202311 values less than ('2023-12-01'),
partition p202312 values less than ('2024-01-01'),
partition pmax values less than (maxvalue));
~~~

### 方法2

1、因为分区表要求分区字段 CREATE_TIME 必须不为空，所以首先查看表中是否存在空值

~~~sql
select count(*) from test where create_time is null or '';
~~~

2、如果分区字段 CREATE_TIME 存在空值，必须修改为不为空的值或者删除空值数据（由业务开发决定）

~~~sql
update test set create_time='2022-08-07 11:11:11' where 1=1;
或者
delete from test where create_time is null or '';
~~~

3、修改分区字段 CREATE_TIME 默认值不为空；

~~~sql
alter table test modify create_time datetime not null comment '创建时间';
~~~

4、修改主键（主键删除和新增必须放一起，否则阻塞dml）；

~~~sql
alter table test drop primary key,add primary key (create_time,id);
~~~

5、新建表结构相同的分区表；

~~~sql
create table test_new (
id bigint(20) not null auto_increment comment '主键id',
name varchar(200) default null,
create_time datetime not null default current_timestamp comment '创建时间',
address varchar(200) default null,
primary key (create_time,id),
key idx_name (name),
key idx_id (id)
) engine=innodb auto_increment=2293142 default charset=utf8mb4 comment='测试表'
partition by range columns(create_time)
(partition p202301 values less than ('2023-02-01') engine = innodb,
partition p202302 values less than ('2023-03-01') engine = innodb,
partition p202303 values less than ('2023-04-01') engine = innodb,
partition p202304 values less than ('2023-05-01') engine = innodb,
partition p202305 values less than ('2023-06-01') engine = innodb,
partition p202306 values less than ('2023-07-01') engine = innodb,
partition p202307 values less than ('2023-08-01') engine = innodb,
partition p202308 values less than ('2023-09-01') engine = innodb,
partition p202309 values less than ('2023-10-01') engine = innodb,
partition p202310 values less than ('2023-11-01') engine = innodb,
partition p202311 values less than ('2023-12-01') engine = innodb,
partition p202312 values less than ('2024-01-01') engine = innodb,
partition pmax values less than (maxvalue) engine = innodb);
~~~

6、分区表最小分区与非分区表交换（秒级操作）；

~~~sql
alter table test_new exchange partition p202301 with table test without validation;
~~~

7、重命名表名（秒级操作）

~~~sql
alter table test rename test_old;
alter table test_new rename test;
~~~



注意，改造前需检测：

- 准备选取的分区字段是什么类型，存的什么值，是否存在空值；
- 非分区表分区字段最大值是什么，用来确定最小分区时间；
- 主键是否可以改造成联合主键；
- 交换的表与原分区表的字段和索引必须保持一致，索引不能少也不能多；



### 方法3

1. 新建与原表结构相同的分区表；
2. 使用类似drs的数据同步工具，同步原表全量+增量数据到分区表；
3. 找个业务低峰修改表名



### 总结

分区表常用于大表转储的场景，通常都是按时间做range分区，对于历史数据的清理和保留都非常方便，其中：

- 方式一适合允许锁表的场景，否则影响业务。
- 方式二适合大部分场景，且对业务影响较小。
- 方式三适合能使用数据同步工具的场景。

## 常见分区案例

### date字段按年分区

```sql
CREATE TABLE orders (
    order_id INT NOT NULL AUTO_INCREMENT,
    order_date DATE,
    customer_id INT,
    total_amount DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_date)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='这是一个分区表，按月份分区'
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p0 VALUES LESS THAN (2020),
    PARTITION p1 VALUES LESS THAN (2021),
    PARTITION p2 VALUES LESS THAN (2022),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);

-- 插入数据到分区表（向分区表插入了三条订单数据，分别属于不同的分区。）：
INSERT INTO orders (order_date, customer_id, total_amount) VALUES
    ('2021-01-01', 1001, 50.00),
    ('2021-02-15', 1002, 100.00),
    ('2022-03-10', 1003, 200.00);

-- 查询分区表数据（查询了 orders 表中 2021 年的订单数据。）：
SELECT * FROM orders WHERE order_date >= '2021-01-01' AND order_date < '2022-01-01';

-- 更新分区表数据（更新了 orders 表中指定订单的金额。）：
UPDATE orders SET total_amount = 150.00 WHERE order_id = 1 AND order_date = '2021-01-01';

-- 删除分区表数据（删除了 orders 表中 2022 年及之后的订单数据。）：
DELETE FROM orders WHERE order_date >= '2022-01-01';
```



### datetime字段按月分区

要按照 datetime 类型字段按月进行分区，可以使用 MySQL 的范围分区策略和日期函数。下面是一个示例，演示如何按月对表进行分区：

~~~sql
-- 创建了一个名为 my_partitioned_table 的分区表，并根据 event_date 列的范围进行分区。每个分区对应一个月份，范围是从每月的第一天到下一个月的第一天。
CREATE TABLE my_partitioned_table (
    id INT,
    event_date DATETIME
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='这是一个分区表，按月份分区'
PARTITION BY RANGE COLUMNS(event_date) (
    PARTITION p0 VALUES LESS THAN ('2023-01-01'),
    PARTITION p1 VALUES LESS THAN ('2023-02-01'),
    PARTITION p2 VALUES LESS THAN ('2023-03-01'),
    PARTITION p3 VALUES LESS THAN ('2023-04-01'),
    ...
    PARTITION pn VALUES LESS THAN MAXVALUE
);

-- 插入数据（向分区表插入了四条数据，分别属于不同的月份。）
INSERT INTO my_partitioned_table (id, event_date) VALUES
    (1, '2023-01-05'),
    (2, '2023-01-15'),
    (3, '2023-02-10'),
    (4, '2023-03-25');

-- 查询特定月份的数据（查询了 my_partitioned_table 表中 2023 年 2 月的数据）
SELECT * FROM my_partitioned_table PARTITION (p1);
~~~

通过按月分区，可以更加高效地查询特定时间范围内的数据。同时，请确保在插入或更新数据时，将数据插入到正确的分区中，以避免跨分区查询的性能问题。

### datetime 只分月不分年实现

要实现只对分月而不分年的分区，可以使用`MySQL`的范围分区策略。下面是一个示例，演示如何按照月份对表进行分区：

~~~sql
-- 创建了一个名为 my_partitioned_table 的分区表，并根据 event_date 列的月份进行分区。每个分区对应一个月份，范围是从1到12
CREATE TABLE my_partitioned_table (
    id INT,
    event_date DATE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='这是一个分区表，按月份分区'
PARTITION BY RANGE (MONTH(event_date)) (
    PARTITION p0 VALUES LESS THAN (2),
    PARTITION p1 VALUES LESS THAN (3),
    PARTITION p2 VALUES LESS THAN (4),
    PARTITION p3 VALUES LESS THAN (5),
    ...
    PARTITION pn VALUES LESS THAN (13)
);

-- 插入数据到分区表（向分区表插入了四条数据，分别属于不同的月份）
INSERT INTO my_partitioned_table (id, event_date) VALUES
    (1, '2023-01-05'),
    (2, '2023-01-15'),
    (3, '2023-02-10'),
    (4, '2023-03-25');

-- 查询特定月份的数据（查询了 my_partitioned_table 表中2月份的数据）：
SELECT * FROM my_partitioned_table PARTITION (p1);
~~~

通过按照月份进行分区，可以更加高效地查询特定月份的数据。请注意，上述示例没有分区年份，如果需要包含多年的数据，可以将分区范围扩展到跨越多年的月份。同时，请确保在插入或更新数据时，将数据插入到正确的分区中，以避免跨分区查询的性能问题。

### datetime 只分月不分年，查询范围数据

如果只对分月而不分年，并且想要查询两年内的数据，可以使用MySQL的范围-列表混合分区策略。以下是一个示例，演示如何实现该需求

~~~sql
-- 创建了一个名为 my_partitioned_table 的分区表，并根据 event_date 列的年份和月份进行分区。每个年份的分区再根据月份进行子分区。范围分区设置为2022年至2023年的数据
CREATE TABLE my_partitioned_table (
    id INT,
    event_date DATE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='这是一个分区表，按月份分区'
PARTITION BY RANGE (YEAR(event_date))
SUBPARTITION BY LIST (MONTH(event_date)) (
    PARTITION p0 VALUES LESS THAN (2022) (
        SUBPARTITION s0 VALUES IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
    ),
    PARTITION p1 VALUES LESS THAN (2024) (
        SUBPARTITION s1 VALUES IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
    )
);

-- 插入数据到分区表（向分区表插入了四条数据，跨越了两年的数据）
INSERT INTO my_partitioned_table (id, event_date) VALUES
    (1, '2022-12-15'),
    (2, '2023-01-10'),
    (3, '2023-05-20'),
    (4, '2023-12-25');

-- 查询两年内的数据（查询了 my_partitioned_table 表中2022年至2023年的所有数据）
SELECT * FROM my_partitioned_table 
WHERE event_date >= '2022-01-01' AND event_date < '2024-01-01';
~~~

通过使用范围-列表混合分区策略，并根据实际需求设置分区边界和子分区边界，可以实现只对分月不分年，并查询两年内数据的功能

## truncate 分区表

在MySQL中，可以使用 ALTER TABLE 语句来截断（empty）分区表的指定分区。以下是一个示例，演示如何对分区表进行分区截断：

~~~sql
-- 将 my_partitioned_table 替换为您的分区表的名称，将 partition_name 替换为要截断的分区的名称
ALTER TABLE my_partitioned_table TRUNCATE PARTITION partition_name;

-- 如果想要截断多个分区，可以使用逗号分隔不同的分区名称，如下所示
ALTER TABLE my_partitioned_table TRUNCATE PARTITION partition_name1, partition_name2;
~~~

请注意，截断分区将删除该分区中的所有数据，并将分区清空。只有当分区表使用了范围分区或列表分区策略时才能进行分区截断操作

请谨慎执行分区截断操作，因为它会永久删除分区中的数据，并且无法恢复。在执行此操作之前，请确保已经备份了重要的数据

## 创建分区表，id主键报错

报错信息：

~~~shell
A Primary key must include all columns in the tables partition function
~~~

在创建按月分区表时，如果使用了分区函数对表进行分区，主键必须包含表中的所有列，并且还需要包含用于分区的列。这是因为根据分区函数将数据分配到不同的分区时，需要确保每个分区中的数据都具有唯一性。

~~~sql
-- 以下是一个示例，展示如何在创建按月分区表时设置主键，其中包含分区列和其他列
CREATE TABLE my_partitioned_table (
    id INT,
    event_datetime DATETIME,
    -- 其他列
    PRIMARY KEY (event_datetime, id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='这是一个分区表，按月份分区'
PARTITION BY RANGE (MONTH(event_datetime)) (
    -- 分区定义
    PARTITION p0 VALUES LESS THAN (2),
    PARTITION p1 VALUES LESS THAN (3),
    PARTITION p2 VALUES LESS THAN (4),
    PARTITION p3 VALUES LESS THAN (5),
    PARTITION p4 VALUES LESS THAN (6),
    PARTITION p5 VALUES LESS THAN (7),
    PARTITION p6 VALUES LESS THAN (8),
    PARTITION p7 VALUES LESS THAN (9),
    PARTITION p8 VALUES LESS THAN (10),
    PARTITION p9 VALUES LESS THAN (11),
    PARTITION p10 VALUES LESS THAN (12),
    PARTITION p11 VALUES LESS THAN (13)
);
~~~

在上述示例中，我们通过在 CREATE TABLE 语句中指定 PRIMARY KEY 来设置主键。主键包括了分区列 event_datetime 和其他列 id。这样可以确保每个分区中的数据具有唯一性。

请根据您的表结构和需求，调整主键的具体定义。

## 各分区 count 合计

要计算所有分区表中的数据条目总数，可以使用以下示例代码：

~~~sql
SELECT SUM(PARTITION_ROWS) -- TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_NAME = 'your_partitioned_table';
 AND PARTITION_NAME IS NULL;
~~~

在上述示例中，请将 'your_partitioned_table' 替换为您实际的分区表名称。执行此查询后，将返回分区表中所有分区的数据条目总数

请注意，这里使用了 INFORMATION_SCHEMA.PARTITIONS 系统表来获取分区表的相关信息。PARTITION_ROWS 是该表中存储的每个分区的数据行数。通过对所有分区的行数求和，可以得到整个分区表的数据条目总数。

当执行上述查询时，确保拥有足够的权限来访问 INFORMATION_SCHEMA.PARTITIONS 表，并且已正确指定分区表的名称。

## 分区剪枝 （Partition Pruning）

分区剪枝（Partition Pruning）是 MySQL 的优化器在执行查询时自动进行的一种技术，用于排除不相关的分区，以减少扫描的数据量。以下是一个示例来说明分区剪枝的工作原理：

假设有一个按时间分区的表 sales，其中包含 id、date 和 amount 字段。表按每年一个分区进行分区，命名为 p2020、p2021、p2022、等等。现在我们想查询某个时间范围内的销售额。

~~~sql
SELECT SUM(amount)
FROM sales
WHERE date BETWEEN '2021-01-01' AND '2022-12-31';
~~~

在执行上述查询时，MySQL 的优化器会自动应用分区剪枝技术，只选择与查询条件相关的分区进行扫描。在这个示例中，优化器会识别出只有 p2021 和 p2022 这两个分区包含所需的数据，其他分区则可以被排除在外。

通过分区剪枝，优化器会生成一个优化的执行计划，只对涉及的分区进行扫描，从而减少了查询的数据量和处理的开销，提高了查询的性能。

需要注意的是，在使用分区剪枝时，查询条件必须与分区键相关才能生效。如果查询条件不与分区键相关，优化器将无法剪枝分区，会扫描所有的分区。

此外，分区剪枝还可以与其他查询优化技术（如索引使用、统计信息等）结合使用，以提高查询性能。

总之，分区剪枝是 MySQL 的一种自动优化技术，通过排除不相关的分区来减少查询的数据量，从而提高查询性能。它在处理大型分区表和时间范围查询时特别有用。

## 分区表预留空间（默认）

在 Navicat 中创建分区表时，可能会出现 "50100" 的情况，这是由于 Navicat预留了一部分空间用于存储分区信息。

在 MySQL 中，对于每个分区表，都需要一个默认分区（也称为无效分区），以便处理不属于任何其他分区的数据。这个默认分区需要占用一定的空间，即 50100 字节。因此，在 Navicat 中创建分区表时，会为默认分区预留这部分空间。

当你在 Navicat 中创建分区表时，可以忽略这个默认分区，因为它只是用来处理无法匹配到其他分区的数据。如果你没有自定义默认分区的话，MySQL 会自动将这些数据放入默认分区中。

请注意，这个 "50100" 的大小是 MySQL 的默认值，如果你在 MySQL配置中更改了默认值，那么在 Navicat 中创建分区表时，预留的空间大小可能会有所不同。

总结来说，Navicat在创建分区表时会预留一部分空间用于默认分区，这是正常的行为，不需要过多关注。

## MySQL 8.0以下truncate分区表锁表

在MySQL 5.7.30(系统版本)及更早版本中，使用 TRUNCATE TABLE命令对分区表进行操作时会锁定整个表，这可能导致其他会话在执行期间被阻塞。

1、使用 DELETE 命令替代 TRUNCATE：如果 TRUNCATE TABLE 操作会导致表锁定问题，可以考虑改用 DELETE FROM命令来删除表中的所有行。DELETE命令是逐行删除的，因此不会锁定整个表。请注意，DELETE命令在删除大量数据时可能效率较低，因为它会记录日志和生成回滚段。

2、分段 TRUNCATE：将大的分区表拆分成多个较小的分区，然后分别执行 TRUNCATE TABLE 命令。这样可以减少锁定的粒度，并降低对整个表的锁定时间。但是，这种方法需要重构分区表结构，可能会造成一些额外的工作。

3、升级到MySQL 8.0或更高版本：MySQL 8.0引入了一项重要的改进，即针对TRUNCATE TABLE命令的分区锁定进行了优化。在MySQL 8.0及更高版本中，TRUNCATE PARTITION 语法可用于仅清空特定分区而不锁定整个表。因此，升级到MySQL 8.0或更高版本可能是一个解决方案。



**不升级mysql、truncate方案**

如果你不能升级`MySQL`版本，但仍然希望在线执行 `TRUNCATE PARTITION` 操作并避免锁表，可以考虑以下方法：

使用分区交换：将要清空的分区与一个空分区进行交换。这样可以实现快速清空分区的效果，而不会锁定整个表。具体步骤如下：

1、创建一个空的临时分区，可以是已存在的空分区或者新创建的分区。

使用 ALTER TABLE 进行分区交换操作，将要清空的分区与空分区进行交换，例如：

~~~sql
ALTER TABLE your_table EXCHANGE PARTITION p_to_truncate WITH TABLE empty_partition;
~~~

这个操作是原子的，并且不会锁定整个表。

最后，删除交换后的空分区。

通过使用分区交换，你可以在不锁定整个表的情况下快速清空指定的分区。

2、使用临时表(离线)：将要清空的分区数据复制到一个临时表中，并通过 RENAME 操作进行切换。具体步骤如下：

- 创建一个临时表，结构与原分区表相同。
- 使用 INSERT INTO ... SELECT 将要清空的分区数据复制到临时表中。
- 使用 RENAME TABLE 进行表名切换，将原分区表重命名为备份表，将临时表重命名为原分区表的名称。
- 最后，删除备份表。
- 这种方法需要一定的额外存储空间来保存临时表和备份表，但可以实现在线清空分区而不锁定整个表。



## mysql 函数按时间自动分区

https://blog.51cto.com/u_16213377/7259532

## MySQL 自动根据年份动态创建范围分区

https://blog.csdn.net/One_piece111/article/details/132877720

## MySQL创建分区表，并按天自动分区

https://blog.csdn.net/yabingshi_tech/article/details/124170160







# 参考资料

https://www.jb51.net/database/302634f7y.htm

https://www.jb51.net/article/62287.htm

https://zhuanlan.zhihu.com/p/652920025

自动添加分区

https://blog.51cto.com/u_16175470/7299961

MySQL分区表的正确使用方法

https://www.jb51.net/article/154387.htm

MySQL最佳实践之分区表基本类型

https://www.jb51.net/article/187694.htm

MySql数据分区操作之新增分区操作

https://www.jb51.net/article/62287.htm
