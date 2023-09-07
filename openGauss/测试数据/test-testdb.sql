CREATE TABLESPACE test_ts RELATIVE LOCATION 'tablespace/test_ts';
create database testdb;
\c testdb
create user test password 'test@123';
alter database testdb owner to test;
GRANT CREATE ON TABLESPACE test_ts TO test;
set search_path to test;

--创建测试表
create table employees
    ( employee_id    serial    primary key
    , first_name     varchar2(20)
    , last_name      varchar2(25) constraint     emp_last_name_nn  not null
    , email          varchar2(25) constraint     emp_email_nn  not null
    , phone_number   varchar2(20)
    , hire_date      date         constraint     emp_hire_date_nn  not null
    , job_id         int8         constraint     emp_job_nn  not null
    , salary         number(8,2)
    , commission_pct number(4,2)
    , manager_id     int8
    , department_id  int8
    , constraint     emp_salary_min check (salary > 0) 
    --, constraint     emp_email_uk unique (email)
    ) TABLESPACE test_ts;
--生成测试数据
insert into employees
select generate_series(1,100000) as key,
       substr(md5(random()::text),2,5),
       substr(md5(random()::text),2,8),
	   substr(md5(random()::text),2,5)||'@163.com',
	   concat('1',ceiling(random()*9000000000+1000000000)),
	   (random()*(2022-1990)+1990)::int||'-'||(random()*(12-1)+1)::int||'-'||(random()*(28-1)+1)::int,
	   (random()*(50-10)+10)::int,
	   (random()*(10000-3000)+3000)::number(8,2),
	   (random()*(1-0)+0)::number(4,2),
	   (random()*(100-1)+1)::int,
	   (random()*(10-1)+1)::int;