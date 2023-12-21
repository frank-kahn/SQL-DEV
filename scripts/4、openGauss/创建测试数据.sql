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
    ) ;


insert into employees
select generate_series(1,1000) as key,
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


-- 创建分区表

create table test_range_t (id int8,name varchar(100))
partition by range(id)
(
	partition p1 values less than(1000),
	partition p2 values less than(2000),
	partition p3 values less than(3000),
	partition p4 values less than(4000),
	partition p5 values less than(5000),
	partition p6 values less than(6000),
	partition p7 values less than(7000),
	partition p8 values less than(maxvalue),
);

-- 插入数据
insert into test_range_t select generate_series(1,8000),substr(md5(random()::text),2,5);


