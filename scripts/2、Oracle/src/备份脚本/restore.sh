check_path () {
if [ -z $1 ];then
echo "input is null"
exit
fi
if [ ! -d $1 ];then
echo "$i is not exist！！！"
fi

}
check_path









#FS
select 'alter database rename file '''||member||''' to ''/oradata/'||substr(member,instr(member,'/',-1,1)+1,length(member)-instr(member,'/',-1,1)+1)||''';' from v$logfile;
select 'alter database rename file '''||name||''' to ''/oradata/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v$tempfile;
select 'set newname for datafile '''||file#||''' to ''/oradata/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v$datafile;




#ASM
select 'alter database rename file '''||member||''' to ''+DATA'';' from v$logfile;
select 'alter database rename file '''||name||''' to ''+DATA'';' from v$tempfile;
select 'set newname for datafile '''||file#||''' to ''+DATA'';' from v$datafile;