bak_path='/oracle/backup'
asm_path='+data'
max_channel=8
read -p "please input filesystem [FS/ASM]: " fstype


gen_set_newname () {
case $fstype in
FS)
      echo "select 'set newname for datafile '''||file#||''' to ''$bak_path/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v\$datafile;"
     ;;
ASM)
      echo "select 'set newname for datafile '''||file#||''' to ''$asm_path'';' from v\$datafile;"
     ;;
*)
      echo "filesystem error!"
     ;;
esac
}

gen_rename_logfile_tempfile () {
case $fstype in
FS)
      echo "select 'alter database rename file '''||member||''' to ''$bak_path/'||substr(member,instr(member,'/',-1,1)+1,length(member)-instr(member,'/',-1,1)+1)||''';' from v$logfile;"
      echo "select 'alter database rename file '''||name||''' to ''$bak_path/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v$tempfile;"
     ;;
ASM)
      echo "select 'alter database rename file '''||member||''' to ''$asm_path'';' from v$logfile;"
      echo "select 'alter database rename file '''||name||''' to ''$asm_path'';' from v$tempfile;"
     ;;
*)
      echo "filesystem error!"
     ;;
esac
}

gen_rman_restore () {
  gen_set_newname $fstype $bak_path $asm_path > set_newname_$(date +'%Y%m%d').sh
  gen_rename_logfile_tempfile $fstype $bak_path $asm_path > rename_logfile_tempfile_$(date +'%Y%m%d').sh
  chmod +x set_newname_$(date +'%Y%m%d').sh rename_logfile_tempfile_$(date +'%Y%m%d').sh
  echo "#!/bin/sh
  myname=rman_restore_$(date +'%Y%m%d')
  rman target / log=$(myname).log << EOF
  catalog start with $bak_path;
YES
  run
  {" > $(myname).sh
  _loop=1
  while [ $_loop -le $max_channel ]
  do
  echo "allocate channel c$_loop type disk format ;" >> $(myname).sh
  ((_loop++))
  done
  sh set_newname_$(date +'%Y%m%d').sh >> $(myname).sh
  restore database; >> $(myname).sh
  switch datafile all; >> $(myname).sh
  recover database; >> $(myname).sh
}
EOF >> $(myname).sh
  sh rename_logfile_tempfile_$(date +'%Y%m%d').sh >> rename_logfile_tempfile.sql
  sqlplus -s /as sysdba  << eof @ rename_logfile_tempfile.sql > 1.log
eof >> $(myname).sh





}









################## main #####################
gen_set_newname $fstype