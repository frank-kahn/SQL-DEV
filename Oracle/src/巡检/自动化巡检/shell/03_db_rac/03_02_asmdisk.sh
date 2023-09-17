#echo "###ASM磁盘###"
#su - grid  -c"
sqlplus -S "/ as sysasm " << EOF
set line 300
col CREATE_DATE for a10
col name for a15
col path for a25
col state for a10
set pagesize 300
set heading off
set feedback off
select --GROUP_NUMBER,
       --DISK_NUMBER,
       STATE,
       --OS_MB,
       TOTAL_MB,
       FREE_MB,
       --NAME,
       PATH
       --CREATE_DATE,
       --VOTING_FILE
  from v\$asm_disk order by 1,2;
exit;
EOF
