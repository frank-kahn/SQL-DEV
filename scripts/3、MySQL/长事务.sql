-- 查看正在执行的sql
show processlist
select * from information_schema.processlist
where Command <> 'Sleep';

state 字段都有什么状态
'converting HEAP to ondisk' 表示什么意思



-- 查看正在执行的事务
select * from information_schema.innodb_trx;

trx_operation_state 都有什么状态，每种状态代表什么意思
'fetching rows' 代表什么意思