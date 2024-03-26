SELECT ROUND((1-(phy.value / (cur.value + con.value)))*100,2) "Cache Hit Ratio"
FROM v$sysstat cur, v$sysstat con, v$sysstat phy
WHERE cur.name = 'db block gets'
AND con.name = 'consistent gets'
AND phy.name = 'physical reads'
/