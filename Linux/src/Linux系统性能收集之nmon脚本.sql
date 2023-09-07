/*
每天22点运行，300秒收集一次，288次 ，24*60*60/300=288
将输出文件保存到 '/soft/nmon'目录

删除90天之前的收集信息
*/
mkdir /soft/nmon
chmod -R 777 /soft/nmon
crontab -e
0 22 * * * nmon -f -s 300 -c 288 -m /soft/nmon > /dev/null 2>&1
0 23 * * * find /soft/nmon -name *.nmon -atime +90 -exec rm -rf {} \;
