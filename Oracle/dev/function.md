# 函数

## stamp_conv_time

将Oracle数据库的stamp数据转换为可读是时间戳

~~~shell
CREATE OR REPLACE FUNCTION stamp_conv_time (stamp NUMBER)
   RETURN DATE
IS
BEGIN
   RETURN TO_DATE
          (
                TO_CHAR (FLOOR (stamp / (86400 * 31 * 12)) + 1988)
             || '/'
             || TO_CHAR (FLOOR (MOD (stamp / (86400 * 31), 12)) + 1)
             || '/'
             || TO_CHAR (FLOOR (MOD (stamp / 86400, 31)) + 1)
             || ' '
             || TO_CHAR (FLOOR (MOD (stamp / 3600, 24)))
             || ':'
             || TO_CHAR (FLOOR (MOD (stamp / 60, 60)))
             || ':'
             || TO_CHAR (MOD (stamp, 60))
            ,'yyyy-mm-dd hh24:mi:ss'
          );
END;
/
~~~

应用示例

~~~shell
SQL> select stamp,stamp_conv_time(stamp) as conv from v$archived_log where rownum<=3;

     STAMP CONV
---------- -------------------
1034266655 2020-03-05 16:17:35
1034266659 2020-03-05 16:17:39
1034266660 2020-03-05 16:17:40
~~~

参考资料

http://blog.itpub.net/267265/viewspace-2135044/



## 解析Linux时间戳

~~~sql
CREATE OR REPLACE FUNCTION convert_unix_timestamp(unix_ts IN NUMBER) RETURN TIMESTAMP IS
BEGIN
    RETURN TO_TIMESTAMP('1970-01-01', 'YYYY-MM-DD') + NUMTODSINTERVAL(unix_ts, 'SECOND');
END;
/

-- 使用自定义函数
SELECT convert_unix_timestamp(1633046400) AS converted_date FROM dual;   -- 2021年10月1日
~~~

## long 类型转 varchar2

Oracle中的LONG类型有两种：
LONG文本类型，能存储2GB的文本。与VARCHAR2或CHAR类型一样，存储在LONG类型中的文本要进行字符集转换。
LONG RAW类型，能存储2GB的原始二进制数据（不用进行字符集转换的数据）。
在此并不解释如何使用LONG类型，而是会解释为什么你不希望在应用中使用LONG（或LONG RAW）类型。首先要注意的是，Oracle文档在如何处理LONG类型方面描述得很明确。Oracle SQL Reference手册指出：
不要创建带LONG列的表，而应该使用LOB列（CLOB、NCLOB、BLOB）。支持LONG列只是为了保证向后兼容性。

没有内置的函数做转换，写了个最简的处理方法：

~~~sql
CREATE OR REPLACE FUNCTION LONG_TO_CHAR(IN_WHERE      VARCHAR,
                                        IN_TABLE_NAME VARCHAR,
                                        IN_COLUMN     VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET VARCHAR2(32767);
  V_SQL VARCHAR2(2000);
 
BEGIN
  V_SQL := 'select ' || UPPER(IN_COLUMN) || ' from
    ' || UPPER(IN_TABLE_NAME) || ' where ' || IN_WHERE;
  EXECUTE IMMEDIATE V_SQL
    INTO V_RET;
  RETURN V_RET;
END;
/
~~~

使用方法：

~~~sql
-- 视图应用例子
 
WITH ALLVIEW AS
 (SELECT UV.*,
         LONG_TO_CHAR('view_name=''' || VIEW_NAME || '''', 'user_views',
                       'TEXT') VTEXT
    FROM USER_VIEWS UV)
SELECT * FROM ALLVIEW WHERE UPPER(VTEXT) LIKE '%MAP%'
 
 
-- 普通表
SELECT T.*,
       LONG_TO_CHAR('rowid=''' || ROWID || '''', 'conf_user', 'user_profile') VTEXT
  FROM CONF_USER T
~~~







## 测试案例

~~~sql
计算并返回一个员工的年度总薪水，基于其基本工资、工作的年数和一个额外的性能奖金。
这个函数将包含以下几个部分：

1.输入参数：员工的基本工资、工作年数和性能评分。
2.局部变量：用于存储计算过程中的中间值。
3.逻辑处理：根据工作年数和性能评分计算年终奖金。
4.返回值：返回员工的年度总薪水。

CREATE OR REPLACE FUNCTION Calculate_Annual_Salary (
    p_base_salary NUMBER, 
    p_years_worked NUMBER, 
    p_performance_rating NUMBER
) RETURN NUMBER IS

    -- 声明局部变量
    v_annual_bonus NUMBER := 0;
    v_total_salary NUMBER;

BEGIN
    -- 根据工作年数和性能评分计算年终奖金
    IF p_years_worked &gt; 5 THEN
        v_annual_bonus := v_annual_bonus + (p_base_salary * 0.10); -- 超过5年的员工，基本工资的10%作为奖金
    END IF;

    IF p_performance_rating &gt; 8 THEN
        v_annual_bonus := v_annual_bonus + (p_base_salary * 0.15); -- 性能评分超过8，额外15%的奖金
    ELSIF p_performance_rating &gt;= 5 THEN
        v_annual_bonus := v_annual_bonus + (p_base_salary * 0.05); -- 性能评分在5到8之间，额外5%的奖金
    END IF;

    -- 计算总薪水
    v_total_salary := p_base_salary + v_annual_bonus;

    -- 返回总薪水
    RETURN v_total_salary;

END Calculate_Annual_Salary;
/

这个函数可以通过传入基本工资、工作年数和性能评分来调用，例如：
SELECT Calculate_Annual_Salary(50000, 6, 9) FROM dual;

这将返回一个员工的年度总薪水，假设他的基本工资是50,000，工作了6年，并且他的性能评分是9。
请注意，这个函数是示例性质的，并且在真实环境中使用时可能需要根据实际业务逻辑进行调整。另外，确保在你的数据库环境中有适当的权限来创建函数。
~~~

