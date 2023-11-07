delimiter //
create procedure sp_test12_10()
begin
declare n int;
set n=0;
repeat
insert into testdb.test12(name,age)
values(concat('test1',n),22);
commit;
set n=n+1;
until n>=10 end repeat;
end
//
delimiter ;

select count(*) from testdb.test12;





use testdb;
create table test_t02(
id int(10) primary key auto_increment,
name varchar(16),
sex enum('m','w'),
age int(3)
);
insert into test_t02(name,sex,age) values
('test01','w',21),
('test02','w',22),
('test03','m',23),
('test04','m',24),
('test05','w',26);
commit;
select * from test_t02;



create database testdb1 charset gbk;
use testdb1;
create table test_t(
id int,
name varchar(20)
) engine=innodb,charset=gbk;
insert into test_t values(1,'情到');
insert into test_t values(2,'深处');
insert into test_t values(3,'人孤独');
commit;
