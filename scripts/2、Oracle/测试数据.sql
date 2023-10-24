-- 主外键表
create table test_a(a_id1 int,a_name varchar(100)
constraint a_pk primary key(a_id1),
constraint fk_b_id1 foreign key (a_id1) references test_b(b_id1) deferrable initially immediate
);
create table test_b(b_id1 int,b_name varchar(100)
constraint b_pk primary key(b_id1),
constraint fk_a_id1 foreign key (b_id1) references test_a(a_id1) deferrable initially immediate
);


--测试数据
create table test(id int,name varchar(100));
insert into test values(1,'zhangsan');
insert into test values(2,'lisi');
insert into test values(3,'wangwu');
insert into test values(4,'zhaoliu');
insert into test values(5,'qiti');
insert into test values(6,'liumei');



create tablespace test_ts datafile '/u01/app/oracle/oradata/testdb/test1.dbf' size 100m autoextend off;
create user test_user identified by test_user default tablespace test_ts temporary tablespace temp;
grant dba to test_user;
conn test_user/test_user
create table test_user.test_t(id int,name varchar2(10));
insert into test_user.test_t values(1,'test1');
insert into test_user.test_t values(2,'test2');
insert into test_user.test_t values(3,'test3');
insert into test_user.test_t values(4,'test4');
insert into test_user.test_t values(5,'test5');
insert into test_user.test_t values(6,'test6');
insert into test_user.test_t values(7,'test7');
insert into test_user.test_t values(8,'test8');
commit;



-- 创建test01、test02表空间和用户test01、test02
create tablespace test01 datafile '/oracle/oradata/test01.dbf' size 50m;
create tablespace test02 datafile '/oracle/oradata/test02.dbf' size 50m;
create user test01 identified by test01 default tablespace test01;
create user test02 identified by test02 default tablespace test02;
grant dba to test01;
grant dba to test02;
alter user test01 quota unlimited on test01; 
alter user test02 quota unlimited on test02; 

conn test01/test01;
create table test01 (id number(2) primary key,name varchar2(10));
insert into test01 values(1,'test01');
insert into test01 values(2,'test02');
insert into test01 values(3,'test03');
insert into test01 values(4,'test04');
insert into test01 values(5,'test05');
commit;
create table test02 as select * from test01;

conn test02/test02;
create table test01 (id number(2) primary key,name varchar2(10));
insert into test01 values(1,'test01');
insert into test01 values(2,'test02');
insert into test01 values(3,'test03');
insert into test01 values(4,'test04');
insert into test01 values(5,'test05');
commit;
create table test02 as select * from test01;


-- 做个检查点：把缓存数据全部写进数据文件：
alter system checkpoint;
-- 切换日志
alter system switch logfile;

-- 创建目录
create or replace directory bak_dir as '/oracle/backup'; 
grant read,write on directory bak_dir to system; 
grant read,write on directory bak_dir to test01;
