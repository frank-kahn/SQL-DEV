create database testdb;
\c testdb
create user test identified by 'test@123';
grant all privileges to test;
alter database testdb owner to test;

gsql -d testdb -U test -W test@123 -p 12345 -r 

--创建分表，插入数据
create table employees_1
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
    ) ;
insert into employees_1
select generate_series(1,10000) as key,
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

create table employees_2
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
    ) ;
insert into employees_2
select generate_series(1,10000) as key,
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

create table employees_3
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
    ) ;
insert into employees_3
select generate_series(1,10000) as key,
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


create table employees_5
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
    ) ;
insert into employees_5
select generate_series(1,10000) as key,
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


create table employees_6
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
    ) ;
insert into employees_6
select generate_series(1,10000) as key,
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


create table student_1
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
    ) ;
insert into student_1
select generate_series(1,10000) as key,
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

create table student_2
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
    ) ;
insert into student_2
select generate_series(1,10000) as key,
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

create table student_3
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
    ) ;
insert into student_3
select generate_series(1,10000) as key,
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


create table student_5
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
    ) ;
insert into student_5
select generate_series(1,10000) as key,
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


create table student_6
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
    ) ;
insert into student_6
select generate_series(1,10000) as key,
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
