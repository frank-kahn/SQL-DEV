############### 当前逻辑有问题，多次输入错误的字符串，最后一次输入正确的时候，会多次去除尾部的字符
check_path () {
if [ -z "$path" ];then
echo "input is null"
main
fi
if [ ! -d "$path" ];then
echo "$path is not exist or not a directory! "
main
fi
path=$(echo "$path"|awk -F "/" '{print $NF}')
if [ -z "$path" ];then
return 0
else 
return 1
fi
}
main(){
echo "-------------------------------------main menu----------------------------------------"
printf "\n"
printf "please input the path of dir: \n"
read dir 
path=$dir
if check_path ${path}
then
dir=${dir%?}
fi
# pass
}

main
echo $dir




#FS
select 'alter database rename file '''||member||''' to ''/oradata/'||substr(member,instr(member,'/',-1,1)+1,length(member)-instr(member,'/',-1,1)+1)||''';' from v$logfile;
select 'alter database rename file '''||name||''' to ''/oradata/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v$tempfile;
select 'set newname for datafile '''||file#||''' to ''/oradata/'||substr(name,instr(name,'/',-1,1)+1,length(name)-instr(name,'/',-1,1)+1)||''';' from v$datafile;




#ASM
select 'alter database rename file '''||member||''' to ''+DATA'';' from v$logfile;
select 'alter database rename file '''||name||''' to ''+DATA'';' from v$tempfile;
select 'set newname for datafile '''||file#||''' to ''+DATA'';' from v$datafile;