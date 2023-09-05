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
