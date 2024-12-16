# 存储过程案例

语法

~~~sql
CREATE [ OR REPLACE ] PROCEDURE
    name ( [ [ argmode ] [ argname ] argtype [ { DEFAULT | = } default_expr ] [, ...] ] )
  { LANGUAGE lang_name
    | TRANSFORM { FOR TYPE type_name } [, ... ]
    | [ EXTERNAL ] SECURITY INVOKER | [ EXTERNAL ] SECURITY DEFINER
    | SET configuration_parameter { TO value | = value | FROM CURRENT }
    | AS 'definition'
    | AS 'obj_file', 'link_symbol'
  } ...
~~~

简单示例

~~~sql
CREATE PROCEDURE insert_data(a integer, b integer)
LANGUAGE SQL
AS $$
INSERT INTO tbl VALUES (a);
INSERT INTO tbl VALUES (b);
$$;

CALL insert_data(1, 2);



CREATE OR REPLACE
PROCEDURE ADD_JOB_HISTORY()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date,job_id, department_id) 
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END;
$$;
~~~

