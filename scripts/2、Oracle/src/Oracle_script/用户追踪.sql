EXEC DBMS_SYSTEM.set_sql_trace_in_session(sid=>321, serial#=>1234, sql_trace=>FALSE);

--获取跟踪文件名

SELECT p.tracefile FROM v$session s JOIN v$process p ON s.paddr = p.addr WHERE s.sid = 321;

--Tracing all session of a user
---创建以下触发器以启用跟踪用户
CREATE OR REPLACE TRIGGER USER_TRACE_TRG
AFTER LOGON ON DATABASE
BEGIN
    IF USER = 'SCOTT'
  THEN
	execute immediate 'alter session set tracefile_identifier='FXY86'';
    execute immediate 'alter session set events ''10046 trace name context forever, level 12''';
  END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
/