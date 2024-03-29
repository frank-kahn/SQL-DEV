# shell随机数生成的几种方法

## 内置变量$RANDOM

RANDOM 是 Bash 的一个内建函数(而不是常量)，会返回一个在区间 [0, 32767] 内的整数，若超过5位可以加个固定10位整数，然后进行求余。

```shell
[root@testos ~]# echo $RANDOM
5148
[root@testos ~]# echo $RANDOM
24365
```

示例1：生成10以内

```shell
[root@testos ~]# expr $RANDOM % 10 + 1
7
```

示例2：生成指定范围内的随机数

```shell
cat > 1.sh << "EOF"
#!/bin/bash    
function rand(){
    min=$1
    max=$(($2 - $min + 1))
    num=$(($RANDOM+1000000000)) # 增加一个10位的数再求余
    echo $(($num%$max + $min))
}

rand_no=$(rand 1000 2000)
echo $rand_no
exit 0
EOF
```

## 使用awk的随机函数

```shell
[root@testos ~]# awk 'BEGIN{srand();print rand()*1000000}'
912693
```

## 使用date +%s%N

```shell
date +%s%N  # 生成19位数
date +%s%N | cut -c6-13 # 取八位数字
date +%s%N | md5sum | head -c 8 # 八位字母和数字的组合
```

示例：生成1~50的随机数

```shell
cat > 1.sh << "EOF"
#!/bin/bash

function rand(){
    min=$1
    max=$(($2- $min + 1))
    num=$(date +%s%N)
    echo $(($num % $max + $min))
}

rnd=$(rand 1 50)
echo $rnd

exit 0
EOF
```

## openssl rand产生随机数

openssl rand 用于产生指定长度个bytes的随机字符。-base64或-hex对随机字符串进行base64编码或用hex格式显示。

```shell
openssl rand -base64 3 | md5sum | cut -c1-8      # 八位字母和数字的组合
openssl rand -base64 2 | cksum | cut -c1-8       # 八位数字
```

额外补充一下：

```shell
[root@testos ~]# openssl rand  -base64 0 | md5sum | cut -c1-8
d41d8cd9
[root@testos ~]# openssl rand  -base64 0 | md5sum | cut -c1-8
d41d8cd9
[root@testos ~]# openssl rand  -base64 0 | md5sum | cut -c1-8
d41d8cd9
[root@testos ~]# openssl rand  -base64 1 | md5sum | cut -c1-8
cc4395db
[root@testos ~]# openssl rand  -base64 1 | md5sum | cut -c1-8
308933a8
[root@testos ~]# openssl rand  -base64 1 | md5sum | cut -c1-8
b4f234f8
[root@testos ~]# openssl rand  -base64 1 | md5sum | cut -c1-8
417cf945
[root@testos ~]# openssl rand  -base64 0
[root@testos ~]# openssl rand  -base64 0
[root@testos ~]# openssl rand  -base64 1
OA==
[root@testos ~]# openssl rand  -base64 1
oA==
[root@testos ~]# openssl rand  -base64 1
hA==
[root@testos ~]# openssl rand  -base64 1
PA==
[root@testos ~]# openssl rand  -base64 10
FCEuxJMHf7cgfg==
[root@testos ~]# openssl rand  -base64 10
wVXcYxkFmFehrw==
[root@testos ~]# openssl rand  -base64 30
xsmkcDN4coqiNoGbj2AgGgSHl7Io+8FFRswZ19fZ
[root@testos ~]# openssl rand  -base64 30
xCP2A4hsKCqj35k5/0DwHAZjd0zY2dsETTPXncQc
```

通过上面参数-base64后面的值，可以看到，当值为0时，openssl rand -base64 0 输出为空，而非0值时才有输出，没有找到这个具体数值的含义，个人推测是seed(种子)，seed=0,产生的值时一个固定值。

## 通过系统内唯一数据生成随机数（/dev/random及/dev/urandom）

### random

/dev/random是 Linux 上的一个字符设备，里面会源源不断地产生随机数(存储系统当前运行的环境的实时数据), 是阻塞的随机数发生器，读取有时需要等待，可以看作系统某时候的唯一值数据。

一般来说，用 od 命令即可:

```shell
[root@testos ~]# od -An -N2 -i /dev/random
       16060
[root@testos ~]# od -An -N2 -i /dev/random
        2981
[root@testos ~]#
```

这里的 -N2 指定要读取的字节数， -i 则是指定输入。

若要产生特定范围内的随机数，则和使用 $RANDOM 的方法类似:

```shell
# @args <beg> <end>
# return random integer in [<beg>, <end>)
function random_range() {
    local beg=$1
    local end=$2
    echo $(($(od -An -N2 -i /dev/random) % ($end - $beg) + $beg))
}
```

### urandom

/dev/urandom 是非阻塞的随机数产生器，读取时不会产生阻塞，速度更快、安全性较差的随机数发生器。

```shell
# 生成字母数字组合串
cat /dev/urandom | head -n 10 | md5sum | head -c 10
# 生成全字符的随机字符串，含特殊字符（e.g: NO>0/D}I?ln）
cat /dev/urandom | strings -n 8 | head -n 1
# 生成数字加字母的随机字符串，其中 strings -n设置字符串的字符数，head -n并不像是设置输出的行数，更像是seed(种子)。
cat /dev/urandom | sed -e 's/[^a-zA-Z0-9]//g' | strings -n 8 | head -n 1
# urandom的数据很多使用cat会比较慢，在此使用head读20行，cksum将读取文件内容生成唯一的表示整型数据，cut以空格分割然后得到分割的第一个字段数据
head -n 20 /dev/urandom| cksum | cut -d" " -f1
```

示例：使用/dev/urandom生成100~500的随机数

```shell
cat > 1.sh << "EOF"
#!/bin/bash

function rand(){
    min=$1
    max=$(($2 - $min + 1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num % $max + $min))
}

rnd=$(rand 100 500)
echo $rnd

exit 0
EOF
```

## seq + sort

sort 命令有一个 -R 选项，可以根据随机 hash 排序，那么我们就可以用 seq 命令先生成一个整数序列，然后用 sort 的 -R 选项处理取其中一行即可。

```shell
# @args <beg> <end>
# return random integer in [<beg>, <end>]
function random_range {
    local beg=$1
    local end=$2
    seq $beg $end | sort -R | head -n1
}
```

值得注意的是，使用这种方法时，要求的值域可以包含负数区域，而本文的其他方法则要进行不同的处理。

## shuf

shuf 和 `sort -R` 的作用类似，用来根据输入生成随机序列:

```shell
# @args <beg> <end>
# return random integer in [<beg>, <end>]
function random_range {
    shuf -i $1-$2 -n1
}
```

在各种方法中，使用 shuf 命令是最简洁的

## 读取linux的uuid码

UUID码全称是通用唯一识别码 (Universally Unique Identifier, UUID)，UUID格式是：包含32个16进制数字，以“-”连接号分为五段，形式为8-4-4-4-12的32个字符。linux的uuid码也是有内核提供的，在/proc/sys/kernel/random/uuid这个文件内。cat/proc/sys/kernel/random/uuid每次获取到的数据都会不同。

```shell
# 获取不同的随机整数
cat /proc/sys/kernel/random/uuid| cksum | cut -f1 -d" "
# 数字加字母的随机数
cat /proc/sys/kernel/random/uuid| md5sum | cut -c1-8
```

示例: 使用linux uuid 生成100~500随机数

```shell
cat > 1.sh << "EOF"
#!/bin/bash    
    
function rand(){    
    min=$1    
    max=$(($2 - $min + 1))    
    num=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')    
    echo $(($num % $max + $min))    
}    
    
rnd=$(rand 100 500)    
echo $rnd    
    
exit 0
EOF
```



## 从元素池中随机抽取取

```shell
pool=(a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9)
num=${#pool[*]}
result=${pool[$((RANDOM%num))]}
```

用于生成一段特定长度的有数字和字母组成的字符串，字符串中元素来自自定义的池子。

```shell
length=10 
i=1

seq=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
num_seq=${#seq[@]}
  
while [ "$i" -le "$length" ]
do
    seqrand[$i]=${seq[$((RANDOM%num_seq))]}  
    let "i=i+1"  
done  
  
echo "The random string is:"  
for j in ${seqrand[@]}  
do  
    echo -n $j  
done  

echo
```





# 参考资料

https://gavin-wang-note.github.io/2020/07/01/generate_random_number_in_shell/