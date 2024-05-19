-- 查询最近30天活跃的主机和用户信息
select /*+parallel 10*/ distinct h.machine,du.username
from dba_hist_active_sess_history h,dba_users du
where h.user_id=du.user_id
       and session_type != 'BACKGROUND'
	   and h.sql_exec_start >= (sysdate-30);

select distinct username,machine,osuser from gv$session;



-- 杀会话
ALTER SYSTEM KILL SESSION 'sid,serial#,@inst_id' IMMEDIATE;