# Linux互信

## 环境信息

| 主机名  | IP地址        | 备注      |
| ------- | ------------- | --------- |
| testos1 | 192.168.1.101 | 以下简称A |
| testos2 | 192.168.1.102 | 以下简称B |
| testos3 | 192.168.1.103 | 以下简称C |

首先配置各个节点的/etc/hosts文件

~~~shell
cat >> /etc/hosts << EOF
192.168.1.101 testos1
192.168.1.102 testos2
192.168.1.103 testos3
EOF
~~~

## 单节点自互信

~~~shell
#假设该主机的IP为192.168.1.100
ssh-keygen
ssh-copy-id 192.168.1.100
~~~

## 三节点互信

### 环境情况互信操作

~~~shell
#1.分别在A B C创建公钥和私钥
cd
ssh-keygen -t rsa 
#2.在A上执行以下命令,整合公钥文件 
#2.1
ssh testos1 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#2.2
ssh testos2 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#2.3
ssh testos3 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
#3.在A上执行以下命令,分发整合后的公钥文件 
scp ~/.ssh/authorized_keys testos2:~/.ssh/
scp ~/.ssh/authorized_keys testos3:~/.ssh/
#4.把A上的known_hosts文件传到其他BC节点
scp ~/.ssh/known_hosts testos2:~/.ssh/
scp ~/.ssh/known_hosts testos3:~/.ssh/
~~~

### 互信操作说明

~~~shell
1、cd进入到用户的家目录
   ssh-keygen生成公钥私钥对，默认加密方式就是rsa，-t rsa可以不加

2.1 执行完毕 A自己互信成功   
2.2 执行完毕 B-A之间互存了对方的公钥，但是没有指纹认证（B的known_hosts中没有A的信息，B ssh 连接 A需要输入一次yes但是不需要输入密码）
2.3 执行完毕 C-A之间互存了对方的公钥，但是没有指纹认证（C的known_hosts中没有A的信息，C ssh 连接 A需要输入一次yes但是不需要输入密码）
2   执行完毕 A的authorized_keys收集到了ABC三个节点的公钥信息，同时A指纹认证ABC成功，此时 仅有A-A互信成功

3   执行完毕 ABC之间相互持有了对方和自己的公钥，此时真正免密登录的只有 A—A、A-B、A-C，BC上没有known_hosts文件，所以B到其他节点（包含自己），C到其他节点（包含）第一次需要输入一次yes

4   执行完毕 相互之间的互信完成
4   执行完毕 ABC 之间IP和hostname的互相都搞好了  直接ssh就可以互相连接，不用指纹认证
~~~

## 使用脚本互信

~~~shell
#hosts文件信息
cat >> /etc/hosts << EOF
192.168.1.101 testos1
192.168.1.102 testos2
192.168.1.103 testos3
EOF

#下载脚本
wget https://gitcode.net/myneth/tools/-/raw/master/tool/ssh.sh
chmod +x ssh.sh

#执行互信
./ssh.sh -user root -hosts "testos1 testos2 testos3" -advanced -exverify -confirm

chmod 600 /home/root/.ssh/config
~~~



## expect模块自动输入密码(互相未配置成功)

```shell
#每个节点都生成公钥、私钥、ip信息
cd
ssh-keygen -t rsa 

cat > /tmp/ip.txt << "EOF"
192.168.1.191:rootroot
192.168.1.192:rootroot
192.168.1.193:rootroot
EOF



cat > 1.sh << "EOF"
for p in $(cat /tmp/ip.txt)
do
ip=$(echo "$p"|cut -f1 -d ":")
password=$(echo "$p"|cut -f2 -d ":")

expect -c "
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$ip
expect {
\"*yes/no*\" {send \"yes\r\";exp_continue}
\"*password*\r\" {send \"$password\r\";exp_continue}
\"*Password*\r\" {send \"$password\r\";}
}
"
done
EOF
```



## 互信检查

~~~shell
#定义主机数量
node_cnt=3

#互信检查
for i in `tail -$node_cnt /etc/hosts |xargs -n1`;do
ssh $i hostname
done


for i in 192.168.1.19{1..3};do
ssh $i hostname
done
~~~



# ssh config配置

~~~shell
Host   : hostName的别名
HostName： 是目标主机的主机名，也就是平时我们使用ssh后面跟的地址名称。
Port：指定的端口号。
User：指定的登陆用户名。
IdentifyFile：指定的私钥地址。
~~~

案例：testosa配置config文件连接testosb

| 主机名  | IP地址        | 用户 |
| ------- | ------------- | ---- |
| testosa | 192.168.1.100 | omm  |
| testosb | 192.168.1.101 | omm  |



~~~shell
#1、testosa生成密钥对
[omm@testosa ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/omm/.ssh/id_rsa): 
Created directory '/home/omm/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/omm/.ssh/id_rsa.
Your public key has been saved in /home/omm/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:vl+icVY2ntrx6EClvpbHu/juPa1ICC+ooj5LA9r7HvE omm@testosa
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|                 |
|            .    |
|           o     |
|.   .   S o +    |
|o.   o o = = o   |
|.o. . E + Oo*  . |
|..o. o   BoXo*. .|
|o++++   oo=*@o+o |
+----[SHA256]-----+
[omm@testosa ~]$ 

#生成的文件信息
[omm@testosa ~]$ ls -l ~omm/.ssh/
total 8
-rw------- 1 omm dbgrp 1675 Mar 25 14:37 id_rsa
-rw------- 1 omm dbgrp  393 Mar 25 14:37 id_rsa.pub
[omm@testosa ~]$ 

#2、将testosa的公钥要送到testosb上
[omm@testosa ~]$ ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.1.101
/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/omm/.ssh/id_rsa.pub"
The authenticity of host '192.168.1.101 (192.168.1.101)' can't be established.
ECDSA key fingerprint is SHA256:WO28ZmHhSVhGiKvXlkPB1VY1T9VvxTn00gZ69AQfo6A.
ECDSA key fingerprint is MD5:48:67:4b:7a:4e:8c:47:42:36:6e:f1:7d:8f:c0:0e:11.
Are you sure you want to continue connecting (yes/no)? yes
/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
omm@192.168.1.101's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '192.168.1.101'"
and check to make sure that only the key(s) you wanted were added.

[omm@testosa ~]$ 



#3、配置testosa的ssh config文件
[omm@testosa ~]$ cat ~omm/.ssh/config
Host osb
HostName 192.168.1.101
User    omm
identityfile ~/.ssh/id_rsa
[omm@testosa ~]$ 


#4、使用config里面的host连接testosb
[omm@testosa ~]$ ssh osb
Last login: Sat Mar 25 14:48:36 2023 from testosa
[omm@testosb ~]$ 
~~~

# sshpass的安装与使用

使用案例

~~~shell
[root@testosa ~]# sshpass -p 'rootroot' ssh -o StrictHostKeyChecking=no root@192.168.1.103 hostname
Warning: Permanently added '192.168.1.103' (ECDSA) to the list of known hosts.
testosd
[root@testosa ~]# sshpass -p 'rootroot' ssh -o StrictHostKeyChecking=no root@192.168.1.106 hostname
Warning: Permanently added '192.168.1.106' (ECDSA) to the list of known hosts.
testosg
[root@testosa ~]# 
~~~

参考资料

https://blog.csdn.net/weixin_42405670/article/details/127191983

https://blog.csdn.net/weixin_40918067/article/details/117155064

