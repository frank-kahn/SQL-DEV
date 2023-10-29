#创建soft 目录
mkdir /soft

#上传安装文件（11g）和一键安装脚本
cd /soft/
chmod +x OracleShellInstall

[root@testosa:/soft]$ ll
-rwxr-xr-x. 1 oracle oinstall     161014 Jul 26 11:02 OracleShellInstall
-rw-r--r--. 1 oracle oinstall 1395582860 Jul 30  2020 p13390677_112040_Linux-x86-64_1of7.zip
-rw-r--r--. 1 oracle oinstall 1151304589 Jul 30  2020 p13390677_112040_Linux-x86-64_2of7.zip
[root@testosa:/soft]$ 

#挂载光盘镜像
mount /dev/cdrom /mnt


#执行一键安装命令
./OracleShellInstall -lf ens33 `# local ip ifname`\
-n testosa `# hostname`\
-op oracle `# oracle password`\
-d /oracle `# software base dir`\
-ord /oracle/oradata `# data dir`\
-o testdba `# dbname`\
-dp oracle `# sys/system password`\
-ds AL32UTF8 `# database character`\
-ns UTF8 `# national character`\
-redo 100 `# redo size`\
-opd Y `# optimize db`

