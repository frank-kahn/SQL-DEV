https://mp.weixin.qq.com/s/n6zMiG8nRZa5iIEjA-syPQ

# oracle
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle23cfree:1.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle21c_ee_db_21.3.0.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle19clhr_asm_db_12.2.0.3:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle18clhr_rpm_db_12.2.0.2:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_12cr2_ee_lhr_12.2.0.1:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_12cr1_ee_lhr_12.1.0.2:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_11g_ee_lhr_11.2.0.4:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_11g_ee_lhr_11.2.0.3:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_10g_ee_lhr_10.2.0.5:2.0 &
nohup docker pull registry.cn-hangzhou.aliyuncs.com/lhrbest/oracle_10g_ee_lhr_10.2.0.1:2.0 &


# 23c免费开发者版本
docker run -itd --name lhroracle23c -h lhroel87 \
  -p 1530:1521 -p 38389:3389 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true lhrbest/oracle23cfree:1.0 \
  /usr/sbin/init

 docker exec -it lhroel87 bash



# 21c 二进制安装
docker run -d --name lhroracle21c -h lhroracle21c \
  -p 5510:5500 -p 55100:5501 -p 1530:1521  -p 3400:3389 \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --privileged=true lhrbest/oracle21c_ee_db_21.3.0.0 \
  /usr/sbin/init



# 19c ASM
docker run -itd -h lhr2019ocpasm --name lhr2019ocpasm \
  -p 1555:1521 -p 5555:5500 -p 55550:5501 -p 555:22 -p 3400:3389 \
  --privileged=true \
  lhrbest/oracle19clhr_asm_db_12.2.0.3:2.0 init

# 对于ASM，① ASM磁盘脚本：/etc/initASMDISK.sh，请确保脚本/etc/initASMDISK.sh中的内容都可以正常执行
# ② 需要在宿主机上安装以下软件
yum install -y kmod-oracleasm
wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracleasm-support-2.1.11-2.el7.x86_64.rpm
wget https://download.oracle.com/otn_software/asmlib/oracleasmlib-2.0.12-1.el7.x86_64.rpm
rpm -ivh *.rpm

systemctl enable oracleasm.service
oracleasm init
oracleasm status



# 19c rpm方式安装
docker run -itd -h lhrora19c --name lhrora19c  \
  -p 1529:1521 -p 5509:5500 -p 55090:5501 -p 229:22 -p 3399:3389 \
  --privileged=true \
  lhrbest/oracle19clhr_rpm_db_12.2.0.3:2.0 init

# 18c rpm方式安装
docker run -itd -h lhrora18c --name lhrora18c \
  -p 1528:1521 -p 5508:5500 -p 55080:5501 -p 228:22 -p 3398:3389 \
  --privileged=true \
  lhrbest/oracle18clhr_rpm_db_12.2.0.2:2.0 init

# 12.2.0.1 二进制安装
docker run -itd --name lhrora1221 -h lhrora1221 \
  -p 1526:1521 -p 5526:5500 -p 55260:5501 -p 226:22 -p 3396:3389 \
  --privileged=true \
  lhrbest/oracle_12cr2_ee_lhr_12.2.0.1:2.0 init

# 12.1.0.2 二进制安装
docker run -itd --name lhrora1212 -h lhrora1212 \
  -p 1525:1521 -p 5525:5500 -p 55250:5501 -p 225:22 -p 3395:3389 \
  --privileged=true \
  lhrbest/oracle_12cr1_ee_lhr_12.1.0.2:2.0 init

# 11.2.0.4 二进制安装
docker run -itd --name lhrora11204 -h lhrora11204 -p 3394:3389 \
  -p 1524:1521 -p 1124:1158 -p 224:22 \
  --privileged=true \
  lhrbest/oracle_11g_ee_lhr_11.2.0.4:2.0 init

# 11.2.0.3 二进制安装
docker run -itd --name lhrora11203 -h lhrora11203 -p 3393:3389 \
  -p 1523:1521 -p 1123:1158 -p 223:22 \
  --privileged=true \
  lhrbest/oracle_11g_ee_lhr_11.2.0.3:2.0 init

# 10.2.0.5 二进制安装，-h参数不能变
docker run -itd --name lhrora10205 -h lhrora10g -p 3380:3389 \
  -p 1512:1521  -p 212:22 \
  --privileged=true \
  lhrbest/oracle_10g_ee_lhr_10.2.0.5:2.0 init


# 10.2.0.1 二进制安装，-h参数不能变
docker run -itd --name lhrora10201 -h lhrora10g -p 3379:3389 \
  -p 1511:1521  -p 211:22 \
  --privileged=true \
  lhrbest/oracle_10g_ee_lhr_10.2.0.1:2.0 init