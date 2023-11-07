#后台执行命令
nohup test.sh > nohup.test.log 2>&1 &

2> 1.log 表示把错误的日志打印到1.log


#每十秒执行一次脚本
* * * * *  /home/gauss/1.sh >> 1.log
* * * * * sleep 10; /home/gauss/1.sh >> 1.log
* * * * * sleep 20; /home/gauss/1.sh >> 1.log
* * * * * sleep 30; /home/gauss/1.sh >> 1.log
* * * * * sleep 40; /home/gauss/1.sh >> 1.log
* * * * * sleep 50; /home/gauss/1.sh >> 1.log

# 一直执行的命令
while(true);do echo yaokang is a good boy!;sleep 1;done
