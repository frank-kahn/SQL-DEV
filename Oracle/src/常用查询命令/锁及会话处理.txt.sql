0.关键视图信息
显示会话的具体信息：v$sessions
显示所有活动事务的信息：v$trx
显示事务等待信息：v$trxwait
显示活动事务视图信息：v$trx_view
显示当前系统中锁的状态：v$lock
显示死锁的历史信息：v$deadlock_history

1.查询当前事务的ID
select trx_id from v$sessions where sess_id = sessid();
定位锁等待问题

2.查看被挂起的事务
select 
   vtw.id as trx_id,
   vs.sess_id      ,
   vs.sql_text     ,
   vs.appname      ,
   vs.clnt_ip
from
   v$trxwait vtw,
   v$trx vt,
   v$sessions vs
where
    vtw.id=vt.id(+)
and vt.sess_id=vs.sess_id(+);

3.通过挂起事务id（trx_id值）找到它等待的事务。
select wait_for_id, wait_time from v$trxwait where id=321646;

4.通过等待事务id（wait_for_id值）定位到连接以及执行的语句		
select 
   vt.id as trx_id,
   vs.sess_id      ,
   vs.sql_text     ,
   vs.appname      ,
   vs.clnt_ip
from
   v$trx vt,
   v$sessions vs
where
   vt.sess_id=vs.sess_id(+)
and
   vt.id = 321643;  

5.sp_close_session(sess_id)关闭等待事务（插入或者更新就要等回滚结束之后，会话才会杀掉）
sp_close_session(142344256);





