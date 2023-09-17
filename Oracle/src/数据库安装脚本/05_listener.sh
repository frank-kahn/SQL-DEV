su - oracle -c "cat <<eof >> /oracle/app/oracle/product/11.2/db/network/admin/listener.ora
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.31.100)(PORT = 1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = cjc)
      (ORACLE_HOME = /oracle/app/oracle/product/11.2/db)
      (SID_NAME = cjc)
    )
  )
eof"
