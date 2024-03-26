-- FOR RAC
SELECT
s.inst_id,
s.blocking_session,
s.sid,
s.serial#,
s.seconds_in_wait
FROM
gv$session s
WHERE
blocking_session IS NOT NULL;