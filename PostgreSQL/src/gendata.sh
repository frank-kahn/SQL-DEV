#!/bin/bash

mkdir -p /postgresql/test_ts

psql -U postgres -c "create user test password 'test';"
psql -U postgres -c "create user user1 password 'test';"
psql -U postgres -c "CREATE TABLESPACE test_ts OWNER test LOCATION '/postgresql/test_ts';"
psql -U postgres -c "create database testdb tablespace test_ts;"
psql -U postgres -d testdb -c "CREATE SCHEMA AUTHORIZATION test;"

psql -U test -d testdb -q << "EOF"
-- 创建域
create domain phone_type as text constraint phone_check check (VALUE ~ '^\d{11}$');
-- 创建数据类型
CREATE TYPE human_sex AS ENUM ('male', 'female');
CREATE TYPE test_type AS (f1 int, f2 text);
-- 创建序列
create sequence employees_s;
create sequence employees_s1;
-- 创建测试表
create table test_t1(id int);
create table test_t2(id int);
create table test_t3(id int);
create table test_t4(id int);
create table employees
    ( employee_id    int8    primary key
    , first_name     varchar(20)
    , last_name      varchar(25)
    , sex            human_sex
    , email          varchar(25)
    , phone_number   phone_type
    , salary         numeric(8,2)
    , last_update_date timestamp
    , constraint     emp_salary_min check (salary > 0) 
    , constraint     emp_email_uk unique (email)
    ) ;

-- 插入数据
insert into employees values(nextval('employees_s'),'King','Johnn','male','johnn@163.com','15145264084',10000,now());

-- 创建索引
create index idx_name on employees(first_name,last_name);
-- 创建约束
ALTER TABLE employees ADD CONSTRAINT check_salary CHECK (salary>0);
-- 普通视图
create view emp as select * from employees;
-- 物化视图
create materialized view emp_v as select * from employees;
refresh materialized view emp_v;

-- 触发器
CREATE OR REPLACE FUNCTION update_time_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_update_date := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_time_trigger BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_time_column();

-- 函数
CREATE FUNCTION inc(val integer) RETURNS integer AS $$
BEGIN
  RETURN val + 1;
END;
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION inc(val1 integer,val2 integer) RETURNS integer AS $$
BEGIN
  RETURN val1 + val2;
END;
$$ LANGUAGE PLPGSQL;


-- 存储过程
CREATE OR REPLACE PROCEDURE test_sum(a NUMERIC,b NUMERIC,C NUMERIC)
AS $$
DECLARE
  val int;
BEGIN
  val := a+b+c;
  RAISE NOTICE 'Total is : % !',val;
END;
$$ language plpgsql;
EOF
