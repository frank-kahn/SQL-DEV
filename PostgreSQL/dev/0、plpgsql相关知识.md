# 第20章 PostgreSQL 存储过程基本知识

## PL/pgSQL 块结构

```sql
[ <<label>> ]		
[DECLARE 
	declarations ]
BEGIN
	statements;
	...
END [label];
```

每个块都由两部分组成，声明和内容

一个块可有可选的标签位于块头和块尾

DECLARE是选的，是定义所有变量的地方，
声明部分是以分号结尾的
内容是必须的，内容部分也是以分号结尾的

```sql
DO $$
<<first_block>>
DECLARE 
	counter integer := 0;
BEGIN
	counter := counter + 1;
	RAISE NOTICE 'The current value of conter is %', counter;
END first_block $$;
```

上面的do语句不属于块的一部分，常常用于执行一个匿名的块，PG是在9.0引入

RAISE NOTICE 是postgresql的一个语句

$$是单引号的替换，当我们去开发pl/pgsql块的时候，一个函数甚至一个存储工具我们必须传送它的内容，以字符串的新式传送，必须逃逸所有单引号字符





**pl/pgsql的子块**

pl/pgsql允许放置一个块在其它块的内部，也就是子块，外部的块叫做outer_block，内部的叫做sub-block

子块用于分组报表，可分为更小更合乎逻辑的一个字块，子块中的变量可以有名字的外块，不建议在外部的变量引用到内部，当我们声明一个变量具有相同的名字的外块时，外块的变量是隐藏在子块中的

```sql
DO $$ 
<<outer_block>>
DECLARE
  counter integer := 0;
BEGIN 
   counter := counter + 1;
   RAISE NOTICE 'The current value of counter is %', counter;
   DECLARE 
	   counter integer := 0;
   BEGIN 
	   counter := counter + 10;
	   RAISE NOTICE 'The current value of counter in the subblock is %', counter;
	   RAISE NOTICE 'The current value of counter in the outer block is %', outer_block.counter;
   END;
   RAISE NOTICE 'The current value of counter in the outer block is %', counter;
END outer_block $$;

NOTICE:  The current value of counter is 1
NOTICE:  The current value of counter in the subblock is 10
NOTICE:  The current value of counter in the outer block is 1
NOTICE:  The current value of counter in the outer block is 1
DO
```

## PostgreSQL存储过程中的变量

变量是存储在内存中的，与特定的数据类型相关联，可以使用块和函数来改变变量的值，使用变量之前需要声明变量。

### 语法结构

```sql
variable_name data_type [:=expression];

DO $$
DECLARE
	counter 	INTEGER := 1;
	first_name 	VARCHAR(50) := 'John';
	last_name 	VARCHAR(50) := 'Doe';
	payment NUMERIC(11,2) = 20.5;
BEGIN
	RAISE NOTICE '% % % has been paid % USD',counter, first_name, last_name, payment;
END $$;

NOTICE:  1 John Doe has been paid 20.50 USD
DO
```

### 案例

postgresql评估的默认值，因此设置变量，当块评估变量的缺省值和设置的是进入，即在进入块内容的时候，去评估区值和设置。

```sql
DO $$
DECLARE
   created_at time := NOW();
BEGIN
   RAISE NOTICE '%', created_at;
   PERFORM pg_sleep(10);
   RAISE NOTICE '%', created_at;
END $$;

NOTICE:  22:31:03.042015
NOTICE:  22:31:03.042015
DO
```

如上为什么两个时间是一样的，而不是间隔10秒，因为now()值已经赋给created_at了，即便是十秒后，还是之前的值，即created_at的值只初始化一次，不会进行第二次初始化

### 复制数据类型

```sql
variable_name table_name.clumn_name%TYPE;
variable_name variable%TYPE;
```

不需要关心该列的数据类型

当该列的数据类型发生变化时，不需要改变变量声明的函数来适应新的变化

可以去引用类型的变量的数据类型的函数值来创建多态的函数内部变量的类型

```sql
-- city_name变量和name列具有相同的数据类型
city_name city.name%TYPE := 'San Francisco';
```

### 分配一个别名给变量

```sql
new_name ALIAS FOR old_name;
```

## PostgreSQL存储过程中的常量

常量初始化之后就不能更改，常量使代码更易懂

```sql
selling_price = net_price + net_price * 0.1
selling_price = net_price + net_price * VAT
```

声明常量语法：

```sql
constant_name CONSTANT data_type := expression
```



案例

```sql
-- 定义增值说税率为常量
DO $$
DECLARE
	VAT CONSTANT NUMERIC := 0.1;
	net_price	 NUMERIC := 20.5;
BEGIN
	RAISE NOTICE 'The selling price is %', net_price * (1+VAT);
END $$;

NOTICE:  The selling price is 22.55
DO

-- 尝试在存储过程中修改常量
DO $$
DECLARE
	VAT CONSTANT NUMERIC := 0.1;
	net_price	 NUMERIC := 20.5;
BEGIN
    VAT = VAT+1;
	RAISE NOTICE 'The selling price is %', net_price * (1+VAT);
END $$;

ERROR:  variable "vat" is declared CONSTANT
LINE 6:     VAT = VAT+1;
            ^
```



postgresql在评估常量的值时候，是在运行的时候进行评估，而不是在编译的时候，也就是每次调用的时候就评估一次

```sql
DO $$
DECLARE
	start_at CONSTANT time := now();
BEGIN
	RAISE NOTICE 'Start executing block at %', start_at;
END $$;
```

## PostgreSQL存储过程错误和消息的提交

语法

```sql
RAISE LEVEL format;
```

format是个字符或者是个指定的消息，使用#号，括号括起来，将会替代消息的参数。括号的数量必须匹配参数的数量，否则postgresql会报错

消息级别：

- DEBUG
- LOG
- NOTICE
- INFO
- WARNING
- EXCEPTION：没有指定级别，模式使用的是EXCEPTION级别，去报告一个错误以及停止当前的事



```sql
DO $$
BEGIN
	RAISE INFO 'information message %',now();
	RAISE LOG 'log message %', now();
	RAISE DEBUG 'debug message %', now();
	RAISE WARNING 'warning message %', now();
	RAISE NOTICE 'notice message %', now();
END $$;

INFO:  information message 2024-07-15 22:41:57.117453+08
WARNING:  warning message 2024-07-15 22:41:57.117453+08
NOTICE:  notice message 2024-07-15 22:41:57.117453+08
DO
```

如上显示了3条记录，是因为不是所有的消息报告都走客户端的，如何控制消息报告到客户端？通过一个client name message和local name message配置的参数

如何提示一个错误消息，可以使用expression级别在RAISE语句中

```sql
USING option = expression    -- expression为错误消息的文本
```

option（选项）可以有以下几种：

- MESSAGE: 错误信息
- HINT: 提供提示消息
- DETAIL: 提供详细信息
- ERROCODE: 提供了错误代码



```sql
-- 重复报错，并返回提示的信息
DO $$ 
DECLARE
   email varchar(255) := 'info@xiodi.cn';
BEGIN 
  -- check email for duplicate
  -- ...
  -- report duplicate email
  RAISE EXCEPTION 'Duplicate email: %', email 
	  USING HINT = 'Check the email again';
END $$;

ERROR:  Duplicate email: info@xiodi.cn
HINT:  Check the email again
CONTEXT:  PL/pgSQL function inline_code_block line 8 at RAISE

-- 错误代码
DO $$ 
BEGIN 
   --...
   RAISE SQLSTATE '2210B';
END $$;

ERROR:  2210B
CONTEXT:  PL/pgSQL function inline_code_block line 4 at RAISE

-- 无效的表达式
DO $$ 
BEGIN 
   --...
   RAISE invalid_regular_expression;
END $$;

ERROR:  invalid_regular_expression
CONTEXT:  PL/pgSQL function inline_code_block line 4 at RAISE
```

# 第21章 PostgreSQL 用户自定义函数

## 创建存储过程/函数

语法结构

```sql
CREATE FUNCTION function_name(p1 type, p2 type)
RETURNS type AS
BEGIN
-- logic
END;
LANGUAGE language_name;
```

为什么最后要写语言呢？因为postgresql也可以使用其它语言去写函数

函数可能有任意一个单一的引号，我们需要去逃避它，可以用$符号逃避，创建函数必须是一个引用的字符串

8.20开始postgresql提供了引用的功能，允许我们选择合适的字符不会影响函数，以便我们不必逃避它

```sql
CREATE FUNCTION inc(val integer) RETURNS integer AS $$
BEGIN
RETURN val + 1;
END; $$
LANGUAGE PLPGSQL;

SELECT inc(20);
SELECT inc(inc(20));
```

<font color = 'red' > 在postgresql中具有不同参数的函数，可以共享相同的名称 </font>



## PostgreSQL函数中的参数

### IN参数

```sql
CREATE OR REPLACE FUNCTION get_sum (
	a NUMERIC,
	b NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
	RETURN a + b;
END; $$
LANGUAGE plpgsql;

postgres=# SELECT get_sum(10,20);
 get_sum
---------
      30
(1 row)
```

如上有两个参数，并且返回都是数字

默认的参数类型在postgresql中都是in参数，因此可以传递in参数到函数中，但是不能获得结果的一部分

### OUT参数

```sql
CREATE OR REPLACE FUNCTION hi_lo(
	a NUMERIC,
	b NUMERIC,
	C NUMERIC,
	OUT hi NUMERIC,
	OUT lo NUMERIC)
AS $$
BEGIN
	hi := GREATEST(a,b,c);
	lo := LEAST(a,b,c);
END; $$
language plpgsql;

postgres=# SELECT hi_lo(10,20,30);
  hi_lo
---------
 (30,10)
(1 row)
postgres=# SELECT * FROM hi_lo(10,20,30);
 hi | lo
----+----
 30 | 10
(1 row)
```

out参数是作为函数参数的一部分进行定义的，返回的结果作为结果的一部分，postgresql支持out参数是从8.1开始的

使用了out参数，所以不需要return语句

out参数在不定义自定义类型而需要返回多个参数中非常有用

返回的是一个自定义的类型

### INOUT参数

```sql
CREATE OR REPLACE FUNCTION square(
	INOUT a NUMERIC)
AS $$
BEGIN
	a := a * a ;
END; $$
LANGUAGE plpgsql;

postgres=# SELECT square(4);
 square
--------
     16
(1 row)

postgres=# SELECT * FROM square(4);
 a
----
 16
(1 row)
```

inout参数是in和out参数的合并，调用着可以传送值到函数中，这个函数然后改变这个参数，改变之后把这个值作为结果的一部分传送回来

### VARIADIC参数

```sql
CREATE OR REPLACE FUNCTION sum_avg(
	VARIADIC list NUMERIC[],
	OUT total NUMERIC,
	OUT average NUMERIC)
AS $$
BEGIN
	SELECT INTO total SUM(list[i])
	FROM generate_subscripts(list, 1) g(i);
	
	SELECT INTO average AVG(list[i])
	FROM generate_subscripts(list, 1) g(i);
END $$
LANGUAGE plpgsql;

postgres=# SELECT * FROM sum_avg(10,20,30);
 total |       average
-------+---------------------
    60 | 20.0000000000000000
(1 row)
```



generate_subscripts函数说明：

使用该函数，生成数组下标值

generate_subscripts(list,1) 输出数组list的下标值从1开始

参数解释:(list为一个数组，1表示该数组只有一层)

```sql
postgres=# select generate_subscripts(array['a','b','c','d'],1);
 generate_subscripts
---------------------
                   1
                   2
                   3
                   4
(4 rows)
```

postgresql函数也接收可变的参数，但是有个条件，所以的参数都必须有相同的数据类型，传递给函数的参数是个数组



## PL/pgSQL 函数重载

postgresql中定义函数可以有相同名字，参数不同就可以，假如多个函数有相同的名字的话，我们叫这些函数是一个函数重载

```sql
-- 算出某个顾客借书的总天数
CREATE OR REPLACE FUNCTION get_rental_duration(p_customer_id INTEGER)
   RETURNS INTEGER AS $$
DECLARE 
   rental_duration INTEGER; 
BEGIN
   -- get the rate based on film_id
   SELECT INTO rental_duration SUM( EXTRACT( DAY FROM return_date - rental_date)) 
	FROM rental 
   WHERE customer_id=p_customer_id;
   RETURN rental_duration;
END; $$
LANGUAGE plpgsql;

dvdrental=# SELECT get_rental_duration(232);
 get_rental_duration
---------------------
                  90
(1 row)
```



函数重载

```sql
-- 获取针对指定日期到还书日期之间的间隔天数
CREATE OR REPLACE FUNCTION get_rental_duration(p_customer_id INTEGER, p_from_date DATE)
   RETURNS INTEGER AS $$
DECLARE 
   rental_duration integer;
BEGIN
   -- get the rental duration based on customer_id and rental date
   SELECT INTO rental_duration
			   SUM( EXTRACT( DAY FROM return_date + '12:00:00' - rental_date)) 
   FROM rental 
   WHERE customer_id= p_customer_id AND 
		rental_date >= p_from_date;
	
   RETURN rental_duration;
END; $$
LANGUAGE plpgsql;

dvdrental=# SELECT get_rental_duration(232,'2005-07-01');
 get_rental_duration
---------------------
                  85
(1 row)
```



重载中默认值的使用

```sql
CREATE OR REPLACE FUNCTION get_rental_duration(
	  p_customer_id INTEGER, 
	  p_from_date DATE DEFAULT '2005-01-01'
   )
   RETURNS INTEGER AS $$
DECLARE 
   rental_duration integer;
BEGIN
   -- get the rental duration based on customer_id and rental date
   SELECT INTO rental_duration
			   SUM( EXTRACT( DAY FROM return_date + '12:00:00' - rental_date)) 
   FROM rental 
   WHERE customer_id= p_customer_id AND 
		rental_date >= p_from_date;
   RETURN rental_duration;
END; $$
LANGUAGE plpgsql;
```



使用一个参数尝试调用这个函数

```sql
dvdrental=# select get_rental_duration(232);
ERROR:  function get_rental_duration(integer) is not unique
LINE 1: select get_rental_duration(232);
               ^
HINT:  Could not choose a best candidate function. You might need to add explicit type casts.
```

原因是这样的：

```sql
select (select nspname from PG_NAMESPACE where oid =pronamespace) as pronamespace, 
        proname,
        proargtypes,
        prorettype 
from pg_proc 
where proname ~* 'get_rental_duration';

 pronamespace |       proname       | proargtypes | prorettype
--------------+---------------------+-------------+------------
 public       | get_rental_duration | 23          |         23
 public       | get_rental_duration | 23 1082     |         23
(2 rows)
```

如上我们创建了两个同名的函数，第一个函数一个参数，第二个函数两个参数，第二个函数的第二个参数设置了默认值，因此在调用的时候，只给一个参数值，两个函数都满足调用的的条件，系统不知道使用调用哪个函数，因此报错

此时可以删除第一个函数就可以了

```sql
DROP FUNCTION get_rental_duration(INTEGER);
```

## PostgreSQL通过函数返回表

```sql
CREATE OR REPLACE FUNCTION get_film(p_pattern VARCHAR)
	RETURNS TABLE(
		film_title VARCHAR,
		film_release_year INT
)
AS $$
BEGIN
	RETURN QUERY SELECT
		title,
		cast(release_year as integer)
	FROM
		film
	WHERE
		title LIKE p_pattern;
END; $$
language 'plpgsql';

dvdrental=# SELECT * FROM get_film('Al%');
    film_title    | film_release_year
------------------+-------------------
 Alabama Devil    |              2006
 Aladdin Calendar |              2006
 Alamo Videotape  |              2006
 Alaska Phantom   |              2006
 Ali Forever      |              2006
 Alice Fantasia   |              2006
 Alien Center     |              2006
 Alley Evolution  |              2006
 Alone Trip       |              2006
 Alter Victory    |              2006
(10 rows)

dvdrental=# SELECT get_film('Al%');
         get_film
---------------------------
 ("Alabama Devil",2006)
 ("Aladdin Calendar",2006)
 ("Alamo Videotape",2006)
 ("Alaska Phantom",2006)
 ("Ali Forever",2006)
 ("Alice Fantasia",2006)
 ("Alien Center",2006)
 ("Alley Evolution",2006)
 ("Alone Trip",2006)
 ("Alter Victory",2006)
(10 rows)


CREATE OR REPLACE FUNCTION get_film(p_pattern VARCHAR,p_year INT)
	RETURNS TABLE(
		film_title VARCHAR,
		film_release_year INT
	) AS $$
DECLARE 
	var_r record;
BEGIN
	FOR var_r IN(SELECT
					title,
					release_year
				 FROM film
			  WHERE title LIKE p_pattern AND
							   release_year = p_year)
	LOOP
		film_title := upper(var_r.title);
	film_release_year := var_r.release_year;
		RETURN NEXT;
	end LOOP;
end; $$
LANGUAGE 'plpgsql';


dvdrental=# SELECT * FROM get_film('%er',2006);
         film_title          | film_release_year
-----------------------------+-------------------
 ACE GOLDFINGER              |              2006
 ALI FOREVER                 |              2006
 FURY MURDER                 |              2006
 ......
 WANDA CHAMBER               |              2006
 WATERSHIP FRONTIER          |              2006
 WISDOM WORKER               |              2006
 WORDS HUNTER                |              2006
 WORST BANGER                |              2006
(78 rows)
```

# 第22章 PostgreSQL 控制结构

## PostgreSQL IF判断语句

### IF THEN

语法

```sql
IF condition THEN
	statement
END IF;
```

案例

```sql
DO $$
DECLARE
	a integer := 10;
	b integer := 20;
BEGIN
	IF a > b THEN
		RAISE NOTICE 'a is greater than b';
	END IF;
	
	IF a < b THEN
		RAISE NOTICE 'a is less than b';
	END IF;
	
	IF a = b THEN
		RAISE NOTICE 'a is equal to b';
	END IF;
END $$;
```

### IF THEN ELSE

语法

```sql
IF condition THEN
	statements;
ELSE
	alternative-statements;
END IF;
```

案例

```sql
DO $$
DECLARE
	a integer := 10;
	b integer := 20;
BEGIN
	IF a > b THEN
		RAISE NOTICE 'a is greater than b';
	ELSE
		RAISE NOTICE 'a is not greater than b';
	END IF;
END $$;
```

### IF THEN ELSIF THEN ELSE

语法

```sql
IF condition-1 THEN
	if-statement;
ELSIF condition-2  THEN
	elsif-statement-2
...
ELSIF condition-n THEN
	elsif-statement-n;
ELSE
	else-statement;
END IF;
```

案例

```sql
DO $$
DECLARE 
	a integer := 10;
	b integer := 10;
BEGIN
	IF a > b THEN
		RAISE NOTICE 'a is greater than b';
	ELSIF a < b THEN
		RAISE NOTICE 'a is less than b';
	ELSE
		RAISE NOTICE 'a is equal to b';
	END IF;
END $$;
```

## PostgreSQL CASE语句

### 简单的CASE语句

语法结构

```sql
CASE search-pression 
	WHERE expression_1[, expression_2,...] THEN
		when-statements
	[...]
	[ELSE
		else-statements]
END CASE;
```

案例

```sql
CREATE OR REPLACE FUNCTION get_price_segment(p_film_id integer)
	RETURNS VARCHAR(50) AS $$
DECLARE
	rate NUMERIC;
	price_segment VARCHAR(50);
BEGIN
	SELECT INTO rate rental_rate
	FROM film
	WHERE film_id = p_film_id;
	
	CASE rate
	WHEN 0.99 THEN price_segment = 'Mass';
	WHEN 2.99 THEN price_segment = 'Mainstream';
	WHEN 4.99 THEN price_segment = 'High End';
	ELSE price_segment = 'Unspectified'; END CASE;
	 
	RETURN price_segment; 
END; $$
LANGUAGE plpgsql;


dvdrental=# SELECT get_price_segment(123) AS "Price-Segment";
 Price-Segment
---------------
 High End
(1 row)
```

### 可搜索的CASE语句

语法结构

```sql
CASE
	WHEN boolean-expression-1 THEN
		statements
	[WHEN boolean-expression-2 THEN
		statements
	...]
	[ELSE 
		statements]
END CASE;
```

案例

```sql
CREATE OR REPLACE FUNCTION get_customer_service (p_customer_id INTEGER)
	RETURNS VARCHAR(25) AS $$
DECLARE
	total_payment NUMERIC;
	service_level VARCHAR(25);
BEGIN
	SELECT INTO total_payment SUM(amount) FROM payment
	WHERE customer_id = p_customer_id;
 
 CASE 
	WHEN total_payment > 200 THEN service_level = 'Platinum';
	WHEN total_payment > 100 THEN service_level = 'Gold';
	ELSE service_level = 'Sliver';
	END CASE;
	RETURN service_level;
END; $$
LANGUAGE plpgsql;


SELECT 148 AS customer,	get_customer_service(148)
UNION
SELECT 178 AS customer,	get_customer_service(178)
UNION
SELECT 81 AS customer, get_customer_service(81);

 customer | get_customer_service
----------+----------------------
      178 | Gold
       81 | Sliver
      148 | Platinum
(3 rows)
```

## PostgreSQL loop循环

PostgreSQL提供三种循环语句

- loop
- while
- for



### loop循环语法结构

```sql
<<label>>
LOOP
	statements;
	EXIT [<<lable>>] WHEN condition;
END LOOP;
/* condition 为真停止循环*/
```

案例

```sql
-- 斐波那契数列（去除0）
CREATE OR REPLACE FUNCTION fibonacci (n INTEGER)
	RETURNS INTEGER AS $$
DECLARE
	counter INTEGER := 0;
	i INTEGER := 0;
	j INTEGER := 1;
BEGIN
	
	IF (n < 1) THEN
		RETURN 0;
	END IF;
	
	LOOP
		EXIT WHEN counter = n;
		counter := counter + 1 ;
	SELECT j, i +j INTO i, j;
	END LOOP;
	
	RETURN i;
END ;
$$ LANGUAGE plpgsql;
```

### while循环

语法结构

```sql
[<<label>>]
WHILE condition LOOP
	statements;
END LOOP;
/* condition 为假则中止*/
```

案例

```sql
CREATE OR REPLACE FUNCTION fibonacci (n INTEGER)
	RETURNS INTEGER AS $$
DECLARE
	counter INTEGER := 0;
	i INTEGER := 0;
	j INTEGER := 1;
	
BEGIN
	IF (n < 1) THEN
		RETURN 0;
	END IF;
	WHILE counter < n LOOP
		counter := counter + 1;
		SELECT j, i + j INTO i, j;
	END LOOP;
	RETURN i;
END; $$
language plpgsql;
```



## PostgreSQL for循环

语法结构

```sql
[<<label>>]
FOR loop_counter IN [REVERSE] from .... to [BY expression] LOOP
	statements
END LOOP [label];
```

postgresql创建整数的变量loop_counter在已存在的循环内部，默认loop_counter是在每个迭代中添加的，假如使用REVERSE关键字，postgresql将会替代loop_counter，from to指定最小和最大的范围，postgresql在进循环之前评估这个表达式 by语句指定迭代的步骤，忽略的话默认的步骤是1，postgresql也评估这个表达式是在loop条目中

案例

```sql
DO $$
BEGIN
	FOR counter IN 1..5 LOOP
	RAISE NOTICE 'Counter: %', counter;
END LOOP;
END; $$;

NOTICE:  Counter: 1
NOTICE:  Counter: 2
NOTICE:  Counter: 3
NOTICE:  Counter: 4
NOTICE:  Counter: 5
DO


DO $$
BEGIN
	FOR counter IN REVERSE 5..1 LOOP
		RAISE NOTICE 'Counter: %', counter;
	END loop;
END; $$;

NOTICE:  Counter: 5
NOTICE:  Counter: 4
NOTICE:  Counter: 3
NOTICE:  Counter: 2
NOTICE:  Counter: 1
DO


DO $$
BEGIN
	FOR counter IN 1..6 BY 2 LOOP
	RAISE NOTICE 'Counter: %', counter;
END LOOP;
END; $$;

NOTICE:  Counter: 1
NOTICE:  Counter: 3
NOTICE:  Counter: 5
DO
```

自定义函数实例

```sql
CREATE OR REPLACE FUNCTION for_loop_through_query(
   n INTEGER DEFAULT 10
) 
RETURNS VOID AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT title 
          FROM film 
          ORDER BY title
          LIMIT n 
    LOOP 
   RAISE NOTICE '%', rec.title;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

# 第23章 PostgreSQL 游标和存储过程

## postgreSQL游标

总体分为以下步骤:

1. 宣告一个游标
2. 打开一个游标
3. 从结果集抓取行到目标
4. 检查是否还有行需要抓取，如果是，返回到第3步执行，如果不虽，执行第5条。
5. 最终，关闭游标



游标就是把大的表分成多个片段的内容去抓取，为什么要这么做呢？

如果一下子抓取大量的数据，可能会导致内存溢出

这是一种从函数返回大结果集的一种有效的方法



**宣告游标**

```sql
DECLARE my_cursor REFCURSOR;
```

宣告游标示例：

```sql
DECLARE
   cur_films CURSOR FOR SELECT * FROM film;
   cur_films2 CURSOR (year integer) FOR select * from film where release_year = year;
```



**打开未绑定的游标**

```sql
/*没有和select语句绑定*/
OPEN unbound_cursor_variable [[NO] SCROLL] FOR query;

-- 示例：
OPEN my_cursor FOR SELECT * FROM city WHERE counter = p_country;
```



**打开游标并绑定到动态的查询**

```sql
OPEN unbound_cursor_variable[ [ NO ] SCROLL ] 
FOR EXECUTE query_string [USING expression [, ... ] ];

-- 示例;
query := 'SELECT * FROM city ORDER BY '$1'';
OPEN cur_city FOR EXECUTE query USING sort_field;
```



**打开绑定的游标**

因为绑定游标在声明查询时已经绑定到查询，所以在打开查询时，如果需要，只需要将参数传递给查询。

```sql
OPEN cursor_variable[ (name:=value,name:=value,...)];

-- 示例：
OPEN cur_films;
OPEN cur_films2(year:=2005)
```



**游标的使用**

打开游标后,我们可以使用取回,移动,更新或删除语句



**获取下一行**

```sql
FETCH [ direction { FROM | IN } ] cursor_variable INTO target_variable;
```

FETCH语句从游标获取下一行并为其分配target_variable，它可以是一条记录、一个行变量或一个逗号分隔的变量列表。如果没有找到更多的行，target_variable被设置为NULL(s)

默认情况下，如果不显式指定方向，光标将获取下一行。以下内容对游标有效:

```shell
NEXT
LAST
PRIOR
FIRST
ABSOLUTE count
RELATIVE count
FORWARD
BACKWARD
```

注意，向前和向后方向仅适用于使用滚动选项声明的游标。

下面是获取游标的案例

```sql
FETCH cur_films INTO row_film;
FETCH LAST FROM row_film INTO title, release_year;
```



**移动游标**

```sql
MOVE [ direction { FROM | IN } ] cursor_variab
```

如果只想移动光标而不检索任何行，可以使用move语句。该方向接受与FETCH语句相同的值。

```sql
MOVE cur_films2;
MOVE LAST FROM cur_films;
MOVE RELATIVE -1 FROM cur_films;
MOVE FORWARD 3 FROM cur_films;
```



**删除或更新行**

一次光标定位,我们可以通过游标删除或更新行，使用删除当前的或更新当前的声明如下:

```sql
UPDATE table_name 
SET column = value, ... 
WHERE CURRENT OF cursor_variable;
 
DELETE FROM table_name 
WHERE CURRENT OF cursor_variable;
```



**关闭游标**

```sql
CLOSE cursor_variable;
```

CLOSE语句释放资源或释放游标变量，以允许使用OPEN语句再次打开它。



**案例**

下面的get_film_titles(integer)函数接受一个参数，代表电影发布的年份。在这个函数中，我们查询所有发行年份等于传递给函数的发行年份的电影。

我们使用游标来循环这些行，并连接标题和电影上映年份

```sql
CREATE OR REPLACE FUNCTION get_film_titles(p_year INTEGER)
   RETURNS text AS $$
DECLARE 
	titles TEXT DEFAULT '';
	rec_film   RECORD;
	cur_films CURSOR(p_year INTEGER) 
	   FOR SELECT title, release_year
	   FROM film
	   WHERE release_year = p_year;
BEGIN
   -- Open the cursor
   OPEN cur_films(p_year);
   LOOP
	-- fetch row into the film
	  FETCH cur_films INTO rec_film;
	-- exit when no more row to fetch
	  EXIT WHEN NOT FOUND;
	-- build the output
	  IF rec_film.title LIKE '%ful%' THEN 
		 titles := titles || ',' || rec_film.title || ':' || rec_film.release_year;
	  END IF;
   END LOOP;
   -- Close the cursor
   CLOSE cur_films;
   RETURN titles;
END; $$
LANGUAGE plpgsql;


dvdrental=# SELECT get_film_titles(2006);
                                             get_film_titles
----------------------------------------------------------------------------------------------------------
 ,Grosse Wonderful:2006,Day Unfaithful:2006,Reap Unfaithful:2006,Unfaithful Kill:2006,Wonderful Drop:2006
(1 row)
```

## postgreSQL存储过程

用户自定义函数不能够去执行事务，甚至去提交或者回滚当前事务都是不可能的。存储过程是支持事务的，这是两者的区别。

语法结构

```sql
CREATE [OR REPLACE] PROCEDURE procedure_name(parameter_list)
LANGUAGE language_name
AS $$
	store_procedure_body;
$$;
```

案例

```sql
DROP TABLE accounts;
CREATE TABLE accounts(
	id INT GENERATED BY DEFAULT AS IDENTITY,
	name VARCHAR(100) NOT NULL,
	balance DEC(15,2) NOT NULL,
	PRIMARY KEY(id)
);
INSERT INTO accounts(name,balance) VALUES ('Bob',10000);
INSERT INTO accounts(name,balance) VALUES ('Alice',10000);
SELECT * FROM accounts;


CREATE OR REPLACE PROCEDURE transfer(INT, INT, DEC)
LANGUAGE plpgsql
AS $$
BEGIN
   -- subtracting the amount from the sender's account 
   UPDATE accounts
   SET balance = balance - $3
   WHERE id = $1;
   -- adding the amount to the receiver's account
   UPDATE accounts 
   SET balance = balance + $3
   WHERE id = $2 ;
   COMMIT;
END;
$$;

-- 调用存储过程:
CALL stored_procedure_name(parameter_list);
-- 案例：
dvdrental=# CALL transfer(1,2,1000);
CALL

dvdrental=# SELECT * FROM accounts;
 id | name  | balance
----+-------+----------
  1 | Bob   |  9000.00
  2 | Alice | 11000.00
(2 rows)
```

# 第26章 PostgreSQL 触发器

## PostgreSQL 触发器介绍

postgresql触发器是一个函数，当和表关联的事件发生时，触发器能够调用自动的执行，事件可以是下列任何之一：insert、update、delete、truncate，触发器是和某个表关联的，表发生某个事件的时候，触发器自动执行一些动作

触发器是一个特殊的用户定义函数，绑定到一个表上，创建一个新的触发器，必须先定义一个触发函数，然后将这个触发函数绑定到一个表中

触发器和用户自定义函数区别是：事件出发时自动调用

postgresql提供了两种类型的触发器：基于行的和基于语句的，区别的调用次数和在什么时候调用，例如更新语句影响20行，行级触发器将调用20次，语句级的将只调用1次

我们可以指定触发器是在事件之前还是之后进行调用，如果调用一个触发事件，可以跳过当前的操作行，甚至改变行或者更新及插入，如果调用事件后，可以触发所有更改。

触发器是在各种应用程序访问数据库的情况下非常有用，比如在修改数据库中保留某些信息，以便在修改数据时自动运行，例如如果希望保留数据的历史记录，而不需要应用程序具有检查每个事件的逻辑。

还可以使用触发器来维持复杂的数据完整性规则，以及无法在其他地方实现的东西，比如说数据库级别，例如当一个新行添加到客户表时，其它行必须创建一个银行和信用卡的表。

缺点：必须知道存在，并理解其逻辑，以便在数据更改时计算它的影响

postgresql触发器实行SQL标准的语句，触发器在postgresql中还有一些特定的功能，比如postgresql触发器可以针对truncate事件，允许定义基于语句的触发器，postgresql要求我们设置用户自定义的函数作为触发器的动作。

## PostgreSQL 触发器的创建

创建触发器需要完成如下步骤

1. CREATE FUNCTION语句创建一个触发器函数
2. 使用CREATE TRIGGER 语句去绑定一个触发器函数到一个表中



创建触发器函数的结构

```sql
CREATE FUNCTION trigger_function()
  RETURNS trigger AS
```

创建触发器语句

```sql
CREATE TRIGGER trigger_name 
	{BEFORE | AFTER | INSTEAD OF} {event [OR ...]}
	   ON table_name
	   [FOR [EACH] {ROW | STATEMENT}]
		   EXECUTE PROCEDURE trigger_function
```

案例

```sql
DROP TABLE if exists employees;
CREATE TABLE employees(
   id SERIAL PRIMARY KEY,
   first_name VARCHAR(40) NOT NULL,
   last_name VARCHAR(40) NOT NULL);

DROP TABLE if exists employees_audits;
CREATE TABLE employees_audits(
   id SERIAL PRIMARY KEY,
   employee_id INT NOT NULL,
   last_name VARCHAR(40) NOT NULL,
   changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION log_last_name_changes()
RETURNS trigger AS
$BODY$
BEGIN
  IF NEW.last_name <> old.last_name THEN
  INSERT INTO employees_audits(employee_id,last_name,changed_on)
  VALUES(OLD.id,OLD.last_name,now());
  END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;


CREATE TRIGGER last_name_changes
BEFORE UPDATE
ON employees
FOR EACH ROW
EXECUTE PROCEDURE log_last_name_changes();


INSERT INTO employees (first_name, last_name) VALUES ('John', 'Doe');
INSERT INTO employees (first_name, last_name) VALUES ('Lily', 'Bush');

UPDATE employees SET last_name = 'Brown' WHERE ID = 2;

SELECT * FROM employees_audits;

 id | employee_id | last_name |         changed_on
----+-------------+-----------+----------------------------
  1 |           2 | Bush      | 2024-07-16 18:33:56.326799
(1 row)
```

## 删除触发器

```sql
DROP TRIGGER [IF EXISTS] trigger_name
ON table_name [CASCADE | RESTRICT];

/* CASCADE   删除依赖关系*/
```

案例

```sql
CREATE FUNCTION check_staff_user()
	RETURNS TRIGGER
AS $$
BEGIN
	IF length(NEW.username) < 8 OR NEW.username IS NULL THEN
	  RAISE EXCEPTION 'The username cannot be less than 8 characters';
	END IF;
	IF NEW.NAME IS NULL THEN
		RAISE EXCEPTION 'Username cannot be NULL';
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER username_check
	BEFORE INSERT OR UPDATE
ON staff
FOR EACH ROW
EXECUTE procedure check_staff_user();

DROP TRIGGER username_check ON staff;
```

## PostgreSQL 触发器的管理

1、修改触发器语法

```sql
-- 修改触发器的名称
ALTER TRIGGER trigger_name ON table_name 
RENAME TO new_name;

ALTER TRIGGER last_name_changes
ON employees
RENAME TO log_last_name_changes;
```

2、关闭触发器

```sql
ALTER TABLE table_name DISABLE TRIGGER trigger_name | ALL
/*
使用all参数，将关闭所有跟该表关联的触发器
*/
```

关闭触发器始终在数据库中是有效的，当触发器事件发生制，没有触发而已

```sql
ALTER TABLE employees DISABLE TRIGGER log_last_name_changes;

ALTER TABLE employees DISABLE TRIGGER ALL;
```

3、移除触发器

```sql
DROP TRIGGER [IF EXISTS] trigger_name 
ON table_name [RESTRICT | CASCADE]

DROP TRIGGER log_last_name_changes 
ON employees;
```

