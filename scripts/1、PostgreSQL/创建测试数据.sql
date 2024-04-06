-- 创建测试数据库和用户
psql
create user pgbench password 'pgbench';
create database pgbenchdb with owner=pgbench;
\c pgbenchdb
CREATE SCHEMA AUTHORIZATION pgbench;
-- 连接数据库
psql postgresql://pgbench:pgbench@192.168.1.100:15432/pgbenchdb
-- pgbench生成测试数据(10表示数据量为100万)
pgbench -i -s 10 -U pgbench pgbenchdb
-- 开始压测：模拟80个用户，64个线程多并发，每10秒显示一次进度报告，运行60秒
pgbench -n -T 60 -P 10 -c 80 -j 64 -U pgbench pgbenchdb


create table tbl_test (id int, info text, c_time timestamp);
insert into tbl_test select generate_series(1,100000),md5(random()::text),clock_timestamp();


-- 创建测试数据库和用户
psql
create user test password 'test';
create database testdb with owner=test;
\c testdb
CREATE SCHEMA AUTHORIZATION test;


psql -U postgres -c "create user test password 'test'"
psql -U postgres -c "create database testdb with owner=test"
psql -U postgres -d testdb -c "CREATE SCHEMA AUTHORIZATION test"


-- 创建测试表
create table employees
    ( employee_id    int8    primary key
    , first_name     varchar(20)
    , last_name      varchar(25) constraint     emp_last_name_nn  not null
    , email          varchar(25) constraint     emp_email_nn  not null
    , phone_number   varchar(20)
    , hire_date      date         constraint     emp_hire_date_nn  not null
    , job_id         int8         constraint     emp_job_nn  not null
    , salary         numeric(8,2)
    , commission_pct numeric(4,2)
    , manager_id     int8
    , department_id  int8
    , constraint     emp_salary_min check (salary > 0) 
    --, constraint     emp_email_uk unique (email)
    ) ;
-- 生成测试数据
insert into employees
select generate_series(1,1000) as key,
       substr(md5(random()::text),2,5),
       substr(md5(random()::text),2,8),
	   substr(md5(random()::text),2,5)||'@163.com',
	   concat('1',ceiling(random()*9000000000+1000000000)),
	   date((random()*(2022-1990)+1990)::int||'-'||(random()*(12-1)+1)::int||'-'||(random()*(28-1)+1)::int),
	   (random()*(50-10)+10)::int,
	   (random()*(10000-3000)+3000)::numeric(8,2),
	   (random()*(1-0)+0)::numeric(4,2),
	   (random()*(100-1)+1)::int,
	   (random()*(10-1)+1)::int;
insert into employees values (1001,'张三','李四','王五@qq.com',12345678912,now(),1,1,1,1,1);




-- 范围分区
create table tbp(id int,date timestamp(6),col2 text) partition by range(date);

create table tbp_2020 partition of tbp for values from ('2020-01-01') to ('2021-01-01');
create table tbp_2021 partition of tbp for values from ('2021-01-01') to ('2022-01-01');
create table tbp_2022 partition of tbp for values from ('2022-01-01') to ('2023-01-01');
create table tbp_2023 partition of tbp for values from ('2023-01-01') to ('2024-01-01');
-- default
create table tbp_default partition of tbp default;


insert into tbp(id,date,col2)
select generate_series(1,400000) as id ,date((random()*(2023-2020)+2020)::int||'-'||(random()*(12-1)+1)::int||'-'||(random()*(28-1)+1)::int),'test';

