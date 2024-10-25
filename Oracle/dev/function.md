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

