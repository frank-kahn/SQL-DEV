# 常用rman备份脚本

## Linux/unix

### 最小负载rman备份脚本

~~~shell
#!/bin/sh
. ~/.bash_profile
DATE=`date +%Y-%m-%d-%H-%M-%S`
date
rman target / log=/backup/log_$DATE <<eof
run
{
allocate channel c1 type disk maxpiecesize=200M;
sql 'alter system archive log current';
crosscheck archivelog all;
delete noprompt expired backup;
backup as backupset duration 00:10 minimize load database format '/backup/rmanfull_%d_%T_%s_%p.bak';
sql 'alter system archive log current';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup format '/backup/archfull%T%U' archivelog all;
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-1';
backup spfile format '/backup/spfile_%d_%T_%s_%p.bak';
backup current controlfile format '/backup/control_%d_%T_%s_%p.bak';
crosscheck archivelog all;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
report need backup;
release channel c1;
}
date
eof
~~~

### 日常rman备份脚本

rman全备脚本

~~~shell
#!/bin/sh
. ~/.bash_profile
DATE=`date +%Y-%m-%d-%H-%M-%S`
rman target / log=/backup/rmanfull/log/rmanfull_log_$DATE <<eof
run
{
allocate channel c1 type disk;
sql 'alter system archive log current';
crosscheck archivelog all;
delete noprompt expired backup;
backup as backupset database format '/backup/rmanfull/rmanfull_%d_%T_%s_%p.bak';
sql 'alter system archive log current';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup format '/backup/rmanfull/archfull%T%U' archivelog all;
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-3';
backup spfile format '/backup/rmanfull/spfile_%d_%T_%s_%p.bak';
backup current controlfile format '/backup/rmanfull/control_%d_%T_%s_%p.bak';
crosscheck archivelog all;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
report need backup;
release channel c1;
}
eof
find /backup/rmanfull/ -mtime +4 | xargs rm -f
find /backup/rmanfull/log/ -mtime +7 | xargs rm -f
~~~



rman arch全备脚本：

~~~shell
#!/bin/sh
. ~/.bash_profile
DATE=`date +%Y-%m-%d-%H-%M-%S`
rman target / log=/backup/archbak/log/arch_log_$DATE.txt <<eof
run
{
allocate channel c1 type disk;
backup as backupset format '/backup/archbak/arch_%d_%T_%s_%p.bak' archivelog all;
backup spfile format '/backup/archbak/spfile_%d_%T_%s_%p.bak';
backup current controlfile format '/backup/archbak/control_%d_%T_%s_%p.bak';
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-3';
crosscheck archivelog all;
crosscheck backup;
delete noprompt expired backup;
report need backup;
release channel c1;
}
eof

find /backup/archbak/ -mtime +4 | xargs rm -f
find /backup/archbak/log/ -mtime +7 | xargs rm -f
~~~



## Windows平台

### archfull.bat

~~~shell
rman target / cmdfile=D:\backup\scripts\archfull.txt log=D:\backup\scripts\archfull.log

echo 删除过久的备份记录

forfiles /p "D:\backup" /s /m  *.bak /d -15 /c "cmd /c del @path"
forfiles /p "D:\backup" /s /m  ARCHFULL* /d -15 /c "cmd /c del @path"
~~~

### archfull.txt

~~~shell
run
{
allocate channel c1 type disk;
sql 'alter system archive log current';
crosscheck archivelog all;
delete noprompt expired backup;
sql 'alter system archive log current';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup format 'D:\backup\archfull%T%U' archivelog all not backed up 1 times;
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-3';
delete backup of archivelog until time='sysdate-14';
backup spfile format 'D:\backup\spfile_%d_%T_%s_%p.bak';
backup current controlfile format 'D:\backup\control_%d_%T_%s_%p.bak';
crosscheck archivelog all;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
report need backup;
release channel c1;
}
~~~

### rmanfull.bat

~~~shell
rman target / cmdfile=D:\backup\scripts\rmanfull.txt log=D:\backup\scripts\rmanfull.log
copy D:\backup\ARCHFULL* Z:\backup\ /y
copy D:\backup\SPFILE* Z:\backup\ /y
copy D:\backup\CONTROL* Z:\backup\ /y
copy D:\backup\RMANFULL* Z:\backup\ /y


echo 删除过久的备份记录

forfiles /p "Z:\backup" /s /m  *.bak /d -15 /c "cmd /c del @path"
forfiles /p "Z:\backup" /s /m  ARCHFULL* /d -15 /c "cmd /c del @path"
~~~



### rmanfull.txt

~~~shell
run
{
allocate channel c1 type disk;
sql 'alter system archive log current';
crosscheck archivelog all;
delete noprompt expired backup;
backup as backupset database format 'D:\backup\rmanfull_%d_%T_%s_%p.bak' include current controlfile;
sql 'alter system archive log current';
sql 'alter system archive log current';
sql 'alter system archive log current';
backup format 'D:\backup\archfull%T%U' archivelog all not backed up 1 times;
crosscheck archivelog all;
delete noprompt archivelog until time='sysdate-3';
backup spfile format 'D:\backup\spfile_%d_%T_%s_%p.bak';
backup current controlfile format 'D:\backup\control_%d_%T_%s_%p.bak';
crosscheck archivelog all;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
report need backup;
release channel c1;
}
~~~







# 参考资料

https://www.cnblogs.com/orachen/p/15877696.html
