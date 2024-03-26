select a.sid, a.serial#, a.username, b.used_urec used_undo_record, b.used_ublk used_undo_blocks
from v$session a, v$transaction b
where a.saddr=b.ses_addr ;