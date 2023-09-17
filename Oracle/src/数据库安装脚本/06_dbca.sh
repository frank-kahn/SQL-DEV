cat > /soft/scripts/dbca.rsp << EOF
[GENERAL]
RESPONSEFILE_VERSION = "11.2.0"
OPERATION_TYPE = "createDatabase"
[CREATEDATABASE]
GDBNAME = "cjc"
SID = "cjc"
TEMPLATENAME = "General_Purpose.dbc"
CHARACTERSET = "AL32UTF8"
NATIONALCHARACTERSET = "AL16UTF16"
DATAFILEDESTINATION="/oradata"
STORAGETYPE = "FS"
SYSPASSWORD = "oracle"
SYSTEMPASSWORD = "oracle"
EMCONFIGURATION = NONE
EOF

su - oracle -c "dbca -silent -responseFile /soft/scripts/dbca.rsp &" | tee /soft/log/dbca.log
