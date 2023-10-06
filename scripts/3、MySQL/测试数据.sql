delimiter //
create procedure sp_itpux12_10()
begin
declare n int;
set n=0;
repeat
insert into itpuxdb.itpux12(name,age)
values(concat('itpux1',n),22);
commit;
set n=n+1;
until n>=10 end repeat;
end
//
delimiter ;

select count(*) from itpuxdb.itpux12;