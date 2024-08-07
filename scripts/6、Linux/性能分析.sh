# 占用CPU的操作
cat /dev/zero
# 占用内存的操作
dd if=/dev/zero of=/dev/null bs=1024MB
#测试磁盘的写速度
dd if=/dev/zero of=/dev/null
# 造一个2G的文件
dd if=/dev/zero of=/root/test-file bs=1MB count=2000
#查看进程的线程资源使用情况
top -H -p  进程号
top -H -p <PID>
# shell linux中如何用shell写一个占用CPU的脚本
https://www.jb51.net/article/223724.htm


#系统监控
#查看IO
iostat -k -x 1
#查看网络
sar -n DEV 1
#查看热点函数
perf top
perf record
perf report


#iostat
iostat -x 3是一个用于在 Linux 系统上查看磁盘和设备的输入/输出统计信息的命令。该命令将返回一系列指标字段，用于评估磁盘和设备的性能。以下是iostat -x 3 命令返回的各个指标字段的解释：          
%user：表示在给定时间间隔内，CPU 用于处理用户进程的百分比。这是 CPU 时间的一部分，用于执行用户应用程序。          
%nice：表示在给定时间间隔内，CPU 用于处理 nice 优先级的用户进程的百分比。这是 CPU 时间的一部分，用于执行低优先级的用户应用程序。          
%system：表示在给定时间间隔内，CPU 用于处理系统进程的百分比。这是 CPU 时间的一部分，用于执行操作系统内核任务。          
%iowait：表示在给定时间间隔内，CPU 等待磁盘完成输入/输出操作的百分比。这是 CPU 时间的一部分，用于等待磁盘操作完成。          
%steal：表示在给定时间间隔内，由于运行虚拟机或被另一个物理 CPU 偷走，所导致的 CPU 时间的百分比损失。          
%idle：表示在给定时间间隔内，CPU 空闲的百分比。这是 CPU 时间的一部分，表示 CPU 未被使用的时间。          
以下是磁盘相关的字段：          
Device：表示设备的名称，例如 /dev/sda1。          
tps：表示每秒完成的传输次数（每秒的传输操作数）。对于硬盘来说，即每秒钟的 I/O 请求数。          
Reads/s：表示每秒从设备读取的数据量（字节数）。          
Writes/s：表示每秒写入设备的数据量（字节数）。          
rMB/s：表示每秒从设备读取的数据量（以 MB 为单位）。          
wMB/s：表示每秒写入设备的数据量（以 MB 为单位）。          
avgrq-sz：表示平均每个请求的扇区数。          
avgqu-sz：表示平均请求队列长度。          
await：表示平均 I/O 操作等待时间（以毫秒为单位）。          
r_await：表示平均读操作等待时间（以毫秒为单位）。          
w_await：表示平均写入操作等待时间（以毫秒为单位）。          
svctm：表示平均 I/O 操作服务时间（以毫秒为单位）。          
%util：表示设备利用率，即设备正在工作的时间与观察时间的比率          
客户生产环境测试结果w_await搞到30多毫秒。正常的SSD盘，一般在1-3ms,SAS盘4-6ms，剩下的基本就是最老的机械SATA盘。磁盘性能差

#dd命令
dd bs=32k count=20k if=/dev/zero of=test oflag=dsync
这个命令使用dd工具来创建一个名为test的文件，并将它填充为零。参数和选项的解释如下：          
bs=32k：指定每个数据块的大小为 32KB。          
count=20k：指定要写入文件的数据块数量为 20,000。          
if=/dev/zero：指定输入文件为 /dev/zero，它会产生一个无限数量的零字节流。          
of=test：指定输出文件的名称为 test。          
oflag=dsync：要求在每次写入操作后等待数据同步到磁盘。          
使用这个命令可以测试磁盘写入的性能，因为/dev/zero是一个特殊设备，它会生成无限数量的零字节流。通过将这些零写入到文件中，并使用oflag=dsync          
选项确保每次写入操作后都进行数据同步到磁盘，可以测量磁盘写入的性能和延迟          
进程测试写入1M/S，我行生产全量8T的库，在导出导入的时候可以达到9.6M/s。进一步验证了磁盘写入性能差





#负载高分析
vmstat 1 查看第一列（CPU运行进程数），第二列（I/O等待进程数）
然后根据以下命令来定位具体进程线程
ps -elLf|awk '$2~/D/{print $0}'
ps -elLf|awk '$2~/R/{print $0}'


#消耗CPU资源的shell脚本: 使用死循环消耗CPU资源，如果服务器是有多颗CPU，可以选择消耗多少颗CPU的资源：

#! /bin/sh 
# filename killcpu.sh
if [ $# != 1 ] ; then
  echo "USAGE: $0 <CPUs>"
  exit 1;
fi
for i in `seq $1`
do
  echo -ne " 
i=0; 
while true
do
i=i+1; 
done" | /bin/sh &
  pid_array[$i]=$! ;
done
 
for i in "${pid_array[@]}"; do
  echo 'kill ' $i ';';
done




#top 按照CPU使用率降序排序
输入大写P
#top 按照内存使用率降序排序
输入大写M
############################top 按照TIME+ 排序
# 获取top内容保存到文本
top -n 1 -b > /tmp/top.tmp
# 获取文本行数
TPMNUM=`wc -l /tmp/top.tmp | awk '{print $1}'` 
# 获取去除头部信息的实际行数 
NUM=$(( TPMNUM - 7 ))
# 获取除去头部内容的信息,获取最后两列,根据TIME+排序,提取前五的进程
tail -$NUM /tmp/top.tmp | awk '{print $11,$12}' |sort -k1nr| tail -5