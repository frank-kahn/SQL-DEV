#echo "####ASM磁盘组####"
#su - grid  -c"
sqlplus -S "/ as sysasm " << EOF
set line 300
set heading off
set feedback off
col name for a15
col compatibility for a10
select ---group_number,
       name,
       ---block_size,
       total_mb,
       free_mb,
       type
       ---compatibility,
       ---voting_files
  from v\$asm_diskgroup;
exit;
EOF
