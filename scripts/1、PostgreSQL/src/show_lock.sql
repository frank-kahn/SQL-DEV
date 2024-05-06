CREATE VIEW show_lock AS SELECT pid, virtualtransaction AS vxid, locktype AS lock_type,
mode AS lock_mode, granted,
CASE
WHEN virtualxid IS NOT NULL AND transactionid IS NOT NULL
THEN virtualxid || ' ' || transactionid
WHEN virtualxid::text IS NOT NULL
THEN virtualxid
ELSE transactionid::text                                                                                                                                                                                           END AS xid_lock, relname,
page, tuple, classid, objid, objsubid
FROM pg_locks LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
WHERE -- do not show our view’s locks
pid != pg_backend_pid()
-- no need to show self-vxid locks virtualtransaction IS DISTINCT FROM virtualxid
-- granted is ordered earlier
ORDER BY 1, 2, 5 DESC, 6, 3, 4, 7;


