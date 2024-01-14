-- 查看最后的日志信息
SELECT UNIQUE THREAD#, MAX(SEQUENCE#) OVER(PARTITION BY THREAD#) LAST FROM V$ARCHIVED_LOG;

-- 列出所有归档信息
RMAN> list archivelog all;
-- 检查归档信息
RMAN> crosscheck archivelog all;
-- 列出过期的归档日志
RMAN> list expired archivelog all; 
-- 删除过期的归档日志
RMAN> delete expired archivelog all;

-- 删除指定日期归档日志
RMAN> delete archivelog all completed before 'sysdate - n';
-- 删除三天以前的日志
RMAN> delete archivelog all completed before 'sysdate - 3';
-- 删除一小时以前的日志
RMAN> delete archivelog all completed before 'sysdate-1/24';

RMAN> delete archivelog until time 'sysdate - 7';
RMAN> delete archivelog until time "to_date('2023-10-04 23:43:44','yyyy-mm-dd hh24:mi:ss')";
RMAN> delete archivelog until sequence 16;
RMAN> list copy of database archivelog all;

-- 删除所有的归档日志
RMAN> delete archivelog all;

-- 清空v$archived_log
execute sys.dbms_backup_restore.resetCfileSection(11);