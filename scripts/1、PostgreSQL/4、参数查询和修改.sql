-- 参数查询
select name,setting,unit,context from pg_settings where name ~ 'log';

-- 修改
set session default_transaction_read_only = 'off';

alter system set default_transaction_read_only = 'off';
select pg_reload_conf();




[postgres@centos7 ~]$ cat /postgresql/pgdata/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             0.0.0.0/0               scram-sha-256
host    replication     all             0.0.0.0/0               md5
[postgres@centos7 ~]$
-- 修改完pg_hba.conf，可以使用
pg_ctl reload