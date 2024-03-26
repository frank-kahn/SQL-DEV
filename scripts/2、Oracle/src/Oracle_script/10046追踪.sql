--system级别开启/关闭10046 trace追踪
alter system set events '10046 trace name context forever,level 12';
alter system set events '10046 trace name context off';

--session级别开启/关闭10046 trace追踪
alter session set evnets '10046 trace name context forever,level 12';
alter session set events '10046 trace name context off';

--全局设置，在参数文件(pfile/spfile)中增加以下：
/* Event=”10046 trace name context forever,level 12” */

--1、开启10046事件追踪
--alter system set events '10046 trace name context forever,level 12';
alter session set events '10046 trace name context forever,level 12';

--2、在开启事件之前，可以先设置trace的标识
alter session set tracefile_identifier='随便起名';


--！！！执行要跟踪的sql语句（对应的trace文件中有SQL的执行情况）

--3、停止10046事件跟踪
--alter system set events '10046 trace name context off';
alter session set events '10046 trace name context off';

--4、定位本次生成的trace文件
select distinct(m.sid),p.pid,p.tracefile from v$mystat m,v$session s,v$process p where m.sid=s.sid and s.paddr=p.addr;


--5、登录服务器切换到Oracle用户下，使用tkprof工具格式化文件输出
[oracle@localhost ~]$ tkprof /u01/app/oracle/diag/rdbms/orcl/orcl/trace/orcl_ora_118583_TEST.trc output = file_name.txt