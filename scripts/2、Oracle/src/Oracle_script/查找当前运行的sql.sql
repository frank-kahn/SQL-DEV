select sesion.sid,
sesion.username,
optimizer_mode,
hash_value,
address,
cpu_time,
elapsed_time,
sql_text
from v$sqlarea sqlarea, v$session sesion
where sesion.sql_hash_value = sqlarea.hash_value
and sesion.sql_address = sqlarea.address
and sesion.username is not null;