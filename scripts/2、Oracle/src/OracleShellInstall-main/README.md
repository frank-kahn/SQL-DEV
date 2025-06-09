<h1 style="color:red;text-align:center">本脚本一次订阅，永久维护更新！</h1>
<h3 style="color:orage;text-align:center">订阅后请添加作者微信：Lucifer-0622</h3>

# 更新记录
- `2022/04/01`
	- 创建 OracleShellInstall 脚本
- `2022/06/16`
	- 新增参数 -redo
	- 多路控制文件复用
- `2022/06/21`
	- 修复若干 bug；
	- 重写 OracleShellInstall 脚本第二版
- `2022/07/03` 
	- OracleShellInstall 第二版发布
- `2022/07/04` 
	- 修复若干 bug；
	- 重写参数 -pdb；
- `2022/07/05` 
	- 修复若干 bug；
	- 增加参数 -er,-opd；
- `2022/07/06` 
	- 删除参数 -i,-pri1,-pri2
	- 增加参数 -lf,-pf,-ord,-dp
- `2022/07/07`（待测试）
	- 新增 swap 自动配置；
	- 新增参数 -jpa，用于安装 OJVM 补丁；
	- 删除参数 -ri2,-hn1,-hn2,-vi1,-vi2，增加参数 -hn,-ri,-vi，用于支持 rac 3 节点安装；
- `2022/07/08`（待测试）
	- 新增 -am 参数，用于选择 udev 或者 asmlib 方式配置 asm 磁盘；
	- 修复若干 bug；
- `2022/07/11`（部分已测试）
	- 修复若干 bug；
- `2022/07/12`（部分已测试）
	- 修复若干 bug；
- `2022/07/13`（部分已测试）
	- 修复若干 bug；
	- 增加参数 -adc，支持无需脚本配置 asm 磁盘（多路径+udev）；
- `2022/07/15`
	- 删除参数 -dbv，-install_mode；
- `2022/07/17`
	- 优化 19C/21C 安装 OJVM 补丁方式；
	- 修复 bug；
- `2023/04/28`
	- <font color='red'>**rac 模式不限节点数**</font>；
	- 增加参数 -fd 筛选多路径磁盘；
	- 删除 -am 参数，取消 asmlib 方式配置 asm 磁盘；
	- 支持不配置多路径直接udev绑盘；
	- 安装过程输出提示优化，全部汉化；
- `2023/05/07`
	- 增加功能：Linux8 安装 11GR2 单机版（不支持 RAC）
- `2023/05/08`
	- 增加功能：单机 ASM 模式
- `2023/06/08`
	- 增加功能：在麒麟 V10 国产系统安装单机版 Oracle 11GR2，12CR2，19C 版本
- `2023/11/09`
	- 增加功能：支持在 RHEL/OEL 9 安装 Oracle 19C（必须打 RU 补丁至少 19.19 版本以上，rlwrap 版本至少 v0.44）
- `2024/03/18`
	- 增加功能：在欧拉 openEuler 22.03 LTS SP3 国产系统安装单机版 Oracle 11GR2，12CR2，19C 版本
- `2024/03/21`
	- 增加功能：在欧拉 openEuler 22.03 LTS SP3 国产系统安装 Oracle 19C RAC
- `2024/03/25`
	- 适配龙蜥 Anolis 7.9 安装 Oracle 11GR2 单机版
	- 适配龙蜥 Anolis 8.8 安装 Oracle 19C 单机版
- `2024/03/26`
	- 适配 suse 15 sp5 安装 Oracle 19C 单机版
- `2024/03/27`
	- 适配 suse 15 sp5 安装 Oracle 12CR2 单机版	
	- 适配龙蜥 Anolis 8.8 安装 Oracle 12CR2 单机版
- `2024/03/28`
	- 修复麒麟 V10 国产系统安装单机版 Oracle 11GR2 BUG
- `2024/03/29`
	- 适配统信 UOS V20 安装 Oracle 11GR2，12CR2，19C 版本
- `2024/04/09` <font color='yellow'>**第四代版本预上线测试**</font>
	- 新增参数：-giv，支持 GI 和 DB 不同版本安装
	- 新增在欧拉 openEuler 22.03 LTS SP3 国产系统安装 Oracle 11GR2 RAC
	- 修改参数：-o ，新增一键创建多个数据库实例，多个数据库名称以逗号分开
	- 优化脚本安装过程日志输出，美化前端输出，将刷屏日志放到后台执行
	- 增加脚本单步计时以及完整安装计时
	- 优化程序逻辑，增加国产数据库安装前置检查
	- 修复多路径配置时排除系统盘 sda BUG
	- 增加密码复杂度校验，只允许数字和字母，不允许特殊字符
- `2024-04-16`
	- 增加 Fedora 39 安装 Oracle 19C 单机
	- 优化YUM源配置
	- 部分BUG修复
- `2024-04-22`
	- 调整函数顺序，优化部分逻辑
- `2024-05-14` <font color='blue'>**第四代版本正式上线**</font>
    - 完美适配主流国产操作系统：
        - 华为欧拉 openEuler 20\21\22\23
        - 阿里龙蜥 Anolis 7/8
        - 统信 UOS V20 1060a
        - 银河麒麟 Kylin V10 SP3
        - 中标麒麟 NeoKylin V7
    - 美化脚本安装过程输出，更加优雅
    - 增加脚本单步计时以及完整安装计时，更加精确
- `2024-06-18` <font color='blue'>**第五代版本正式上线**</font>
    - **适配 99% 主流 Linux 操作系统以及版本，一网打尽**，具体可参考：[目前脚本已支持操作系统 #12](https://github.com/DBAutoTask/OracleShellInstall/issues/12)
    - 减少绝大多数安装校验，例如必须要安装补丁才能安装等，目前基本支持所有版本基础版安装，非必须安装补丁（包括 11GR2 在 rhel8/9 等安装）
    - 去除 `-iso` 参数，新增参数：`-lrp` 和 `-lnp`，可参考：[脚本配置软件源逻辑更新以及 ISO 挂载教程 #6](https://github.com/DBAutoTask/OracleShellInstall/issues/6)
    - 重写软件源配置部分和软件安装部分
    - 重写操作系统适配部分
    - 去除密码复杂度校验，支持复杂密码
    - 重写在线重做日志逻辑，更加智能化
    - 优化互信逻辑，保证互信成功概率提高
    - 优化脚本逻辑，删除复杂冗余代码，执行速度更快
- `2024-06-21`
    - 新增 `-dbs` 参数，用来指定数据库块大小，默认值为 8192，可选值：[2048|4096|8192|16384|32768]
        - 当 -dbs 参数值不为 8192 时，创建数据库时会走自定义方式，会导致建库特别慢，这个无法避免。
    - 优化 RAC 下检测 ASM 磁盘是否存在磁盘组数据
    - 修复 RAC 创建磁盘组时 AUsize 默认值始终为 1 的 BUG。
    - 重写 DBCA 建库逻辑，使用静默文件方式建库。
- `2024-06-27`
    - 增加 -o 参数值数据库名称和实例名称的检查逻辑
      - 数据库名称超过 8 位提示功能，受限 Oracle，建库时会截取前 8 位作为数据库名称
      - 数据库实例名称超过 15 位报错，受限 Oracle，实例名称无法超过 12 位
      - -o 参数值不能为特殊字符，必须是字母和数字组成，以字母开头
    - 适配 Linux ARM 19C 安装
      - 龙蜥 8.9 安装软件成功，到建库时存在问题，dbca 无法调用，SQL 建库成功
      - OracleLinux 8.5 以上版本官方支持，脚本大概率完全适配，未经验证
- `2024-07-17`
    - 完全适配 Linux ARM 19C 安装，话不多说，自行测试
    - 适配 nvme 盘配置多路径，需要测试 scsi_id 能否获取 wwid
    - 新增参数，用于自定义安装用户名称：
		- ou：系统 oracle 用户名称，默认值：[oracle]
		- gu：系统 grid 用户名称，默认值：[grid]
		- ard：适用于单机模式，Oracle 归档文件目录，默认值：[/oradata/archivelog]
	- 重写函数 clean_old_envir，针对脚本执行多次安装后清理旧环境的方式，目前修改方案为取消脚本自动清理，改为脚本提供清理命令，人为去执行清理。
	- 增加 RAC 模式 VIP 和 SCANIP 的连通性检测，避免被占用的问题。
- `2024-07-27`
  - 适配 23ai 先行版 - For Exadata（非 RPM 安装）
- `2024-08-17`
  - 修复 RHEL9 部分 BUG
  - 增加参数：`-hf` 安装完成是否配置内存大页，默认值：[N]
- `2024-08-22`
  - 增加 openSUSE 适配，修复 SUSE 15.6 removeIPC 配置文件路径问题
  - 修复 Deb 系 gcc 版本升级需要降级问题
  - 优化开机自启脚本配置逻辑
  - 修复数据库字符集不支持问题，目前支持 247 种全部字符集
  - 优化 rh9 系 which 问题导致创建监听失败问题
- `2024-08-26`
  - 适配 Ubuntu（deb）系列安装 Oracle RAC
  - 修复自定义归档路径为空的 BUG
  - 增加脚本调试参数：-debug
  - 修复 grid 用户的 glogin 无法查询名称的问题
  - 增加 grid 用户 rlwrap 配置
- `2024-09-12`
  - 新增适配华为云欧拉 HCE aarch，已测试
- `2024-09-24`
  - 新增适配腾讯 TencentOS 2/3/4，已测试通过
- `2024-10-14`
  - 新增适配浪潮云峦 KeyarchOS 5，已测试通过
- `2024-11-24`
  - 适配 Centos/RHEL 10 安装 Oracle 11G~23ai 单机、单机ASM、RAC
- `2025-01-14`
  - 适配 天翼云 ctyunos 安装 Oracle 11G~23ai 单机、单机ASM、RAC
- `2025-03-05`
  - 适配 龙蜥23.2、openEuler24.09 安装 Oracle 11G~23ai 单机、单机ASM、RAC
- `2025-03-22`
  - 适配 debian12.10 安装 Oracle 11G~23ai 单机、单机ASM、RAC，修复 arm 版本 BUG
  
# 脚本兼容性列表
目前脚本已支持操作系统（已安装验证）：
- [RedHat 6/7/8/9 全系](https://developers.redhat.com/products/rhel/download)
- [OracleLinux 6/7/8/9 全系](https://yum.oracle.com/oracle-linux-isos.html)
- [Centos 6/7/8 全系](https://mirrors.tuna.tsinghua.edu.cn/centos/)
- [Rocky Linux 8/9 全系](https://rockylinux.org/download)
- [AlmaLinux 8/9 全系](https://almalinux.org/get-almalinux)
- [SUSE 12/15 全系](https://www.suse.com/download/sles/)
- [华为欧拉 openEuler 20~24 全系](https://mirrors.tuna.tsinghua.edu.cn/openeuler/)
- [华为欧拉 EulerOS V2 全系](https://tools.mindspore.cn/productrepo/iso/euleros/x86_64/)
- [腾讯 TencentOS 2/3/4 全系](https://mirrors.tencent.com/tlinux/)
- [浪潮云峦 KeyarchOS 5 全系](https://www.ieisystem.com/keyarchos/product-download/index.html)
- [阿里龙蜥 openAnolis 7/8 全系](https://openanolis.cn/download)
- [银河麒麟 Kylin V10 全系](https://sx.ygwid.cn:4431/)
- [中标麒麟 NeoKylin V7 全系](https://sx.ygwid.cn:4431/)
- [统信 UOS V20 全系](https://cdimage-download.chinauos.com/)
- [NingOS](https://www.h3c.com/cn/Service/Document_Software/Software_Download/Server/Catalog/system/system/NingOS/)
- [OpenCloudOS 7/8/9 全系](https://www.opencloudos.tech/ospages/downloadISO)
- [Debian 全系](https://mirrors.tuna.tsinghua.edu.cn/debian-cd/)
- [Deepin 全系](https://mirrors.tuna.tsinghua.edu.cn/deepin-cd/)
- [Ubuntu 全系](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/)
- [ArchLinux](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/)
- [Fedora 13~39 全系](https://fedoraproject.org/zh-Hans/server/download/)
- [红旗 asianux](https://bbs.chinaredflag.cn/?download2.htm)
- [中科方德](https://www.nfschina.com/index.php?catid=24)

## 目前脚本已知支持的 Oracle 版本
Oracle 安装包下载链接：[https://pan.baidu.com/s/1F1yGVmrl9ZHC8QHmcQKK4g?pwd=2na8](https://pan.baidu.com/s/1F1yGVmrl9ZHC8QHmcQKK4g?pwd=2na8) ，出于友情提供，非义务，请勿有多余要求，谢谢合作。
```bash
11GR2
12CR2
19C
21C
```
## 目前脚本已知支持列表组合

| 支持 单机/单机ASM/RAC，已适配 X86_64/ARM | 11GR2 | 12CR2 | 19C | 21C | 23ai |
| ---------------------------------------- | ----- | ----- | --- | --- | ---- |
| Centos >=6 全系                          | ✅     | ✅     | ✅   | ✅   | ✅    |
| RedHat >=6 全系                          | ✅     | ✅     | ✅   | ✅   | ✅    |
| OracleLinux >=6 全系                     | ✅     | ✅     | ✅   | ✅   | ✅    |
| RockyLinux >=8 全系                      | ✅     | ✅     | ✅   | ✅   | ✅    |
| AlmaLinux >=8 全系                       | ✅     | ✅     | ✅   | ✅   | ✅    |
| SUSE >=12 全系                           | ✅     | ✅     | ✅   | ✅   | ✅    |
| openSUSE >=12 全系                       | ✅     | ✅     | ✅   | ✅   | ✅    |
| 华为欧拉 openEuler >=20 全系             | ✅     | ✅     | ✅   | ✅   | ✅    |
| 华为欧拉 EulerOS V2 全系                 | ✅     | ✅     | ✅   | ✅   | ✅    |
| 腾讯 TencentOS >=2 全系                  | ✅     | ✅     | ✅   | ✅   | ✅    |
| 浪潮云峦 KeyarchOS >=5 全系              | ✅     | ✅     | ✅   | ✅   | ✅    |
| 阿里龙蜥 Anolis >=7 全系                 | ✅     | ✅     | ✅   | ✅   | ✅    |
| 银河麒麟 Kylin V10 全系                  | ✅     | ✅     | ✅   | ✅   | ✅    |
| 中标麒麟 NeoKylin V7 全系                | ✅     | ✅     | ✅   | ✅   | ✅    |
| 统信 UOS V20 全系                        | ✅     | ✅     | ✅   | ✅   | ✅    |
| OpenCloudOS >=7 全系                     | ✅     | ✅     | ✅   | ✅   | ✅    |
| Debian 全系                              | ✅     | ✅     | ✅   | ✅   | ✅    |
| Deepin 全系                              | ✅     | ✅     | ✅   | ✅   | ✅    |
| Ubuntu 全系                              | ✅     | ✅     | ✅   | ✅   | ✅    |
| Fedora >=13 全系                         | ✅     | ✅     | ✅   | ✅   | ✅    |
| ArchLinux                                | ✅     | ✅     | ✅   | ✅   | ✅    |
| 红旗 asianux                             | ✅     | ✅     | ✅   | ✅   | ✅    |
| 中科方德                                 | ✅     | ✅     | ✅   | ✅   | ✅    |
| NingOS                                   | ✅     | ✅     | ✅   | ✅   | ✅    |

# 常见问题
- 安装 RAC，主节点外的 ISO 镜像请勿上传到 /soft 目录下挂载，否则会被脚本删除，导致安装失败。
- （生产环境不建议）安装 RAC 测试建议使用 starwind，用 ISCSI 网络挂载 ASM 共享盘，经过多次测试没有问题。
- 挂载 ISO 镜像源，必须使用 Everything 或者比较全的源，否则可能安装失败。

# 实操参考
以下为作者安装测试的教程合集，请仔细阅读：
- [Oracle 一键安装脚本实操合集，持续更新中！！！](https://www.modb.pro/db/1773583263184031744)

# 脚本使用
使用脚本前，务必先做好以下步骤：
- 安装好操作系统，最小化和图形化皆可
- 配置好主机网络
- 配置软件源准备（本地或者网络），脚本会自动配置，只需要挂载 ISO 即可
  - 本地源：挂载本地 ISO 镜像，可参考：[脚本配置软件源逻辑更新以及 ISO 挂载教程 #6](https://github.com/DBAutoTask/OracleShellInstall/issues/6)
  - 网络源：需要连接外网，确保能 ping 通 www.baidu.com 即可，目前只支持（无需上传 rlwrap 插件包，默认网络源会自动安装）：
    - fedora
    - euleros
    - debian
    - ubuntu
    - Deepin
    - arch
- 创建软件存放目录（RAC 只需在主节点创建，上传软件即可）：mkdir /soft
- 上传安装所需软件包：Oracle 安装包下载链接：[https://pan.baidu.com/s/1F1yGVmrl9ZHC8QHmcQKK4g?pwd=2na8](https://pan.baidu.com/s/1F1yGVmrl9ZHC8QHmcQKK4g?pwd=2na8)
  - 安装基础包（必须）
  - 补丁包（非必须）
- 上传一键安装脚本：OracleShellInstall

更详细可以参考：

- **单机**
	- 系统组安装好操作系统（支持最小化安装）
	- 网络组配置好主机网络，通常只需要一个公网 IP 地址
	- DBA 创建软件目录：`mkdir /soft`
	- DBA 上传 Oracle 安装介质（基础包，补丁包）到 /soft 目录下
	- DBA 上传 Oracle 一键安装脚本到 /soft 目录下，授予脚本执行权限：`chmod +x OracleshellInstall`
	- DBA 挂载主机 ISO 镜像，这里只需要 mount 上即可（这个很简单，不了解的可以百度下）
	- 根据脚本安装脚本以及实际情况，配置好脚本的安装参数，在 /soft 目录下执行一键安装即可。
- **单机 ASM**
	- 系统组安装好操作系统（支持最小化安装）
	- 网络组配置好主机网络，通常只需要一个公网 IP 地址
	- 存储组配置并在主机层挂载好 ASM 磁盘，虚拟化环境需要确保已开启磁盘的 UUID
	- DBA 创建软件目录：`mkdir /soft`
	- DBA 上传 Oracle 安装介质（基础包，补丁包）到 /soft 目录下
	- DBA 上传 Oracle 一键安装脚本到 /soft 目录下，授予脚本执行权限：`chmod +x OracleshellInstall`
	- DBA 挂载主机 ISO 镜像，这里只需要 mount 上即可（这个很简单，不了解的可以百度下）
	- 根据脚本安装脚本以及实际情况，配置好脚本的安装参数，在 /soft 目录下执行一键安装即可。
- **RAC**
	- 系统组所有节点均安装好操作系统（支持最小化安装）
	- 网络组所有节点均配置好主机网络，至少需要一组公网 IP 地址和一组心跳 IP 地址
	- 存储组所有节点均配置并在主机层挂载好 ASM 磁盘，至少需要一组 OCR 和 DATA 磁盘组，虚拟化环境需要确保已开启磁盘的 UUID
	- DBA 只需要在主节点创建软件目录：`mkdir /soft`
	- DBA 只需要在主节点上传 Oracle 安装介质（基础包，补丁包）到 /soft 目录下，其他节点无需任何操作
	- DBA 只需要在主节点上传 Oracle 一键安装脚本到 /soft 目录下，授予脚本执行权限：`chmod +x OracleshellInstall`
	- DBA 所有节点均挂载主机 ISO 镜像，这里只需要 mount 上即可（这个很简单，不了解的可以百度下）
	- 根据脚本安装脚本以及实际情况，配置好脚本的安装参数，在主节点的 /soft 目录下执行一键安装即可。


## 参数介绍
关于脚本的参数使用可执行 `./OracleShellInstall -h` 进行查看，使用脚本前强烈建议全部看一遍再执行安装：
```bash

   ███████                             ██          ████████ ██               ██  ██ ██                    ██              ██  ██
  ██░░░░░██                           ░██         ██░░░░░░ ░██              ░██ ░██░██                   ░██             ░██ ░██
 ██     ░░██ ██████  ██████    █████  ░██  █████ ░██       ░██       █████  ░██ ░██░██ ███████   ██████ ██████  ██████   ░██ ░██
░██      ░██░░██░░█ ░░░░░░██  ██░░░██ ░██ ██░░░██░█████████░██████  ██░░░██ ░██ ░██░██░░██░░░██ ██░░░░ ░░░██░  ░░░░░░██  ░██ ░██
░██      ░██ ░██ ░   ███████ ░██  ░░  ░██░███████░░░░░░░░██░██░░░██░███████ ░██ ░██░██ ░██  ░██░░█████   ░██    ███████  ░██ ░██
░░██     ██  ░██    ██░░░░██ ░██   ██ ░██░██░░░░        ░██░██  ░██░██░░░░  ░██ ░██░██ ░██  ░██ ░░░░░██  ░██   ██░░░░██  ░██ ░██
 ░░███████  ░███   ░░████████░░█████  ███░░██████ ████████ ░██  ░██░░██████ ███ ███░██ ███  ░██ ██████   ░░██ ░░████████ ███ ███
  ░░░░░░░   ░░░     ░░░░░░░░  ░░░░░  ░░░  ░░░░░░ ░░░░░░░░  ░░   ░░  ░░░░░░ ░░░ ░░░ ░░ ░░░   ░░ ░░░░░░     ░░   ░░░░░░░░ ░░░ ░░░ 


注意：本脚本仅用于新服务器上实施部署数据库使用，严禁在已运行数据库的主机上执行，以免发生数据丢失或者损坏，造成不可挽回的损失！！！                                                                                  


用法: OracleShellInstall [选项] 对象 { 命令 | help }                                                                                  

单机模式：                                                                                       

-lrp                 配置本地软件源，需要挂载本地 ISO 镜像源，默认值：[Y]                                                   
-nrp                 配置网络软件源，默认值：[N]                                                   
-lf                  [必填] 公网 IP 的网卡名称                                                   
-n                   主机名，默认值：[orcl]
-ou					 系统 oracle 用户名称，默认值：[oracle]                                                   
-op                  系统 oracle 用户密码，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-d                   Oracle 软件安装根目录，默认值：[/u01]                                                   
-ord                 Oracle 数据文件目录，默认值：[/oradata]                                                   
-ard                 Oracle 归档文件目录，默认值：[/oradata/archivelog]                                                 
-o                   Oracle 数据库名称，默认值：[orcl]                                                   
-dp                  Oracle 数据库 sys/system 密码，若包含特殊字符(_,#,$)必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-ds                  数据库字符集，默认值：[AL32UTF8]                                                   
-ns                  数据库国家字符集，默认值：[AL16UTF16]                                                   
-er                  是否启用归档日志，默认值：[true]                                                   
-pdb                 用于 CDB 架构，PDB 名称，支持传入多个PDB：-pdb pdb01,pdb02，默认值：[pdb01]                                                   
-redo                数据库 redo 日志文件大小，单位为 MB，默认值[1024]                                                   
-opa                 Oracle PSU/RU 补丁编号                                                       
-jpa                 Oracle OJVM PSU/RU 补丁编号                                                   
-m                   仅配置操作系统，默认值：[N]                                                   
-ud                  安装到 Oracle 软件结束，默认值：[N]                                                   
-gui                 是否安装系统图形界面，默认值：[N]                                                   
-opd                 安装完成是否优化 Oracle 数据库，默认值：[N]  
-hf                  安装完成是否配置内存大页，默认值：[N]                                                 

单机 ASM 模式：                                                                                  

-lrp                 配置本地软件源，需要挂载本地 ISO 镜像源，默认值：[Y]                                                   
-nrp                 配置网络软件源，默认值：[N]                                                   
-lf                  [必填] 公网 IP 的网卡名称                                                   
-n                   主机名，默认值：[orcl]   
-ou					 系统 oracle 用户名称，默认值：[oracle]                                                 
-op                  系统 oracle 用户密码，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-d                   Oracle 软件安装根目录，默认值：[/u01]                                                   
-ord                 Oracle 数据文件目录，默认值：[/oradata]                                                   
-o                   Oracle 数据库名称，默认值：[orcl]   
-gu					 系统 grid 用户名称，默认值：[grid]                                                 
-gp                  系统 grid 用户密码，，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-dp                  Oracle 数据库 sys/system 密码，若包含特殊字符(_,#,$)必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-adc                 是否需要脚本配置 ASM 磁盘，如果不需要配置，则需要自行提前配置好，默认值：[Y]                                                   
-mp                  是否需要脚本配置 multipath 多路径，如果不需要配置多路径，则使用UDEV直接绑盘，默认值：[Y]                                                   
-dd                  [必填] ASM DATA 磁盘组的磁盘列表，默认传参为(sd名称)：-dd /dev/sdb：若设置参数 -adc N，则传入已配置好的磁盘列表：-dd /dev/asm_data1                                                   
-dn                  ASM DATA 磁盘组名称，默认值：[DATA]                                                   
-dr                  ASM DATA 磁盘组冗余度，默认值：[EXTERNAL]                                                   
-ds                  数据库字符集，默认值：[AL32UTF8]                                                   
-ns                  数据库国家字符集，默认值：[AL16UTF16]                                                   
-er                  是否启用归档日志，默认值：[true]                                                   
-pdb                 用于 CDB 架构，PDB 名称，支持传入多个PDB：-pdb pdb01,pdb02，默认值：[pdb01]                                                   
-redo                数据库 redo 日志文件大小，单位为 MB，默认值[1024]                                                   
-gpa                 Grid PSU/RU 补丁编号                                                         
-opa                 Oracle PSU/RU 补丁编号                                                       
-jpa                 Oracle OJVM PSU/RU 补丁编号                                                   
-m                   仅配置操作系统，默认值：[N]                                                   
-ud                  安装到 Oracle 软件结束，默认值：[N]                                                   
-gui                 是否安装系统图形界面，默认值：[N]                                                   
-opd                 安装完成是否优化 Oracle 数据库，默认值：[N]                                                   
-vbox                在虚拟机 virtualbox 上安装 RAC 时需要设置 -vbox Y，用于修复 BUG，默认值：[N]                                                   
-fd                  过滤多路径磁盘，去除重复路径，获取唯一盘符：参数值为非ASM盘符（系统盘等），例如：-fd /dev/sda，多个盘符用逗号拼接：-fd /dev/sda,/dev/sdb                                             
-hf                  安装完成是否配置内存大页，默认值：[N]                

RAC 模式：                                                                                         

-lrp                 配置本地软件源，需要挂载本地 ISO 镜像源，默认值：[Y]                                                   
-nrp                 配置网络软件源，默认值：[N]                                                   
-lf                  [必填] RAC 所有节点公网 IP 的网卡名称，所有节点需要保持一致，例如：-lf team0                                                   
-pf                  [必填] RAC 所有节点心跳 IP 的网卡名称，最多支持2组心跳，所有节点需要保持一致，例如：-pf eth3,eth4                                                   
-n                   [必填] RAC 所有节点主机名前缀，参数值必须按照节点顺序排序，例如主机名为 orcl01,orcl02，则参数传值：-n orcl，默认值：[orcl]                                                   
-hn                  [必填] RAC 所有节点主机名，参数值必须按照节点顺序排序，例如：-hn orcl01,orcl02                                                   
-ri                  [必填] RAC 所有节点公网 IP 地址，参数值必须按照节点顺序排序，例如：-ri 10.211.55.100,10.211.55.101                                                   
-vi                  [必填] RAC 所有节点虚拟 IP 地址，参数值必须按照节点顺序排序，例如：-vi 10.211.55.102,10.211.55.103                                                   
-si                  [必填] RAC scan IP 地址，单个scan ip无需配置 DNS，3个scan ip则必须配置 DNS，例如：-si 10.211.55.105,10.211.55.106,10.211.55.107                                                   
-d                   Oracle 数据库软件安装根目录 [/u01]                                                   
-rp                  [必填] 系统 root 用户密码，所有节点必须保持一致，用于建立互信，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'      
-gu					 系统 grid 用户名称，默认值：[grid]                                               
-gp                  系统 grid 用户密码，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]   
-ou					 系统 oracle 用户名称，默认值：[oracle]                                                 
-op                  系统 oracle 用户密码，若包含特殊字符必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-cn                  RAC 集群名称，长度不能超过15位，可自定义，默认值：主机名前缀(-n参数)-cluser [orcl-cluster]                                                   
-sn                  RAC scan名称，可自定义，默认值：主机名前缀(-n参数)-scan [orcl-scan]                                                   
-adc                 是否需要脚本配置 ASM 磁盘，如果不需要配置，则需要自行提前配置好，默认值：[Y]                                                   
-mp                  是否需要脚本配置 multipath 多路径，如果不需要配置多路径，则使用UDEV直接绑盘，默认值：[Y]                                                   
-od                  [必填] ASM OCR 磁盘组的磁盘列表，默认传参为(sd名称)：-od /dev/sdb：若设置参数 -adc N，则传入已配置好的磁盘列表：-od /dev/asm_ocr1                                                   
-dd                  [必填] ASM DATA 磁盘组的磁盘列表，传参方式同 -od                                                   
-ad                  ASM 归档日志磁盘组的磁盘列表，传参方式同 -od                                                   
-on                  ASM OCR 磁盘组名称，默认值：[OCR]                                                   
-dn                  ASM DATA 磁盘组名称，默认值：[DATA]                                                   
-an                  ASM ARCH 磁盘组名称，默认值：[ARCH]                                                   
-or                  ASM OCR 磁盘组冗余度，默认值：[EXTERNAL]                                                   
-dr                  ASM DATA 磁盘组冗余度，默认值：[EXTERNAL]                                                   
-ar                  ASM ARCH 磁盘组冗余度，默认值：[EXTERNAL]                                                   
-o                   Oracle 数据库名称，默认值：[orcl]                                                   
-dp                  Oracle 数据库 sys/system 密码，若包含特殊字符(_,#,$)必须以单引号包裹，例如：'Passw0rd#'，默认值：[oracle]                                                   
-ds                  数据库字符集，默认值：[AL32UTF8]                                                   
-ns                  数据库国家字符集，默认值：[AL16UTF16]                                                   
-er                  是否启用归档日志，默认值：[true]                                                   
-pdb                 用于 CDB 架构，PDB 名称，支持传入多个PDB：-pdb pdb01,pdb02，默认值：[pdb01]                                                   
-redo                数据库 redo 日志文件大小，单位为 MB，默认值[1024]                                                   
-tsi                 RAC CTSS 的时间服务器 IP 地址，用于配置所有节点间的时间同步                                                   
-dns                 是否配置 DNS，如果配置多个scan ip，则需要配置 -dns Y，默认值：[N]                                                   
-dnsn                DNS 服务器名称                                                              
-dnsi                DNS 服务器 IP 地址                                                          
-gpa                 Grid PSU/RU 补丁编号                                                         
-opa                 Oracle PSU/RU 补丁编号                                                       
-jpa                 Oracle OJVM PSU/RU 补丁编号                                                   
-m                   仅配置操作系统，默认值：[N]                                                   
-ug                  安装到 Grid 软件结束，默认值：[N]                                                   
-ud                  安装到 Oracle 软件结束，默认值：[N]                                                   
-gui                 是否安装系统图形界面，默认值：[N]                                                   
-opd                 安装完成是否优化 Oracle 数据库，默认值：[N]                                                   
-vbox                在虚拟机 virtualbox 上安装 RAC 时需要设置 -vbox Y，用于修复 BUG，默认值：[N]                                                   
-fd                  过滤多路径磁盘，去除重复路径，获取唯一盘符：参数值为非ASM盘符（系统盘等），例如：-fd /dev/sda，多个盘符用逗号拼接：-fd /dev/sda,/dev/sdb  
-hf                  安装完成是否配置内存大页，默认值：[N]           
```

## 单机
### 最简安装
```bash
./OracleShellInstall -lf eth0 `# 主机网卡名称`
```
### 无补丁安装
```bash
./OracleShellInstall -lf ens33 `# 主机网卡名称`\
-n uos1050d `# 主机名`\
-op oracle `# 主机 oracle 用户密码`\
-d /u01 `# Oracle 软件安装基础目录`\
-ord /oradata `# 数据库文件存放目录`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 100 `# 在线重做日志大小（M）`\
-opd Y `# 是否优化数据库`
```
### 生产环境安装
```bash
./OracleShellInstall -lf ens33 `# 主机网卡名称`\
-n uos1050d `# 主机名`\
-op oracle `# 主机 oracle 用户密码`\
-d /u01 `# Oracle 软件安装基础目录`\
-ord /oradata `# 数据库文件存放目录`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-opa 33806152 `# oracle PSU/RU 补丁编号`\
-jpa 33808367 `# OJVM PSU/RU 补丁编号`\
-opd Y `# 是否优化数据库`
```

## 单机 ASM
### 最简安装
```bash
./OracleShellInstall -lf eth0 `# 主机网卡名称` \
-dd /dev/sdc `# DATA 磁盘盘符名称`
```
### 无补丁安装
```bash
./OracleShellInstall -lf ens33 `# 主机网卡名称`\
-n uos1050d `# 主机名`\
-d /u01 `# Oracle 软件安装基础目录`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-dd /dev/sdc `# DATA 磁盘盘符名称`\
-opd Y `# 是否优化数据库`
```
### 生产环境安装
```bash
./OracleShellInstall -lf ens33 `# 主机网卡名称`\
-n uos1050d `# 主机名`\
-op oracle `# 主机 oracle 用户密码`\
-d /u01 `# Oracle 软件安装基础目录`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-dd /dev/sdc `# DATA 磁盘盘符名称`\
-gpa 35940989 `# grid PSU/RU 补丁编号`\
-opa 35574075 `# oracle PSU/RU 补丁编号`\
-jpa 35685663 `# OJVM PSU/RU 补丁编号`\
-opd Y `# 是否优化数据库`
```

### Grid 和 DB 不同版本
以 `19C Grid` 和 `11GR2 DB` 为例：
```bash
./OracleShellInstall -lf ens33 `# 主机网卡名称`\
-n uos1050d `# 主机名`\
-op oracle `# 主机 oracle 用户密码`\
-d /u01 `# Oracle 软件安装基础目录`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-dd /dev/sdc `# DATA 磁盘盘符名称`\
-gpa 35940989 `# grid PSU/RU 补丁编号`\
-opa 35574075 `# oracle PSU/RU 补丁编号`\
-jpa 35685663 `# OJVM PSU/RU 补丁编号`\
-opd Y `# 是否优化数据库`\
-giv 19 `# Grid 软件版本号`
```

## RAC
### 最简安装
```bash
./OracleShellInstall -n lucifer `# RAC 主机名前缀`\
-rp oracle `# 主机 root 用户密码`\
-lf eth0 `# 主机网卡名称`\
-pf eth1 `# 主机心跳网卡名称`\
-ri 192.168.6.180,192.168.6.181 `# RAC 公网 IP`\
-vi 192.168.6.182,192.168.6.183 `# RAC 虚拟 IP`\
-si 192.168.6.184 `# RAC SCAN IP`\
-od /dev/sdb `# OCR 磁盘盘符名称`\
-dd /dev/sdc `# DATA 磁盘盘符名称`
```

### 无补丁安装
```bash
./OracleShellInstall -n oel `# RAC 主机名前缀`\
-hn oel01,oel02 `# RAC 主机名`\
-cn oel-cls `# RAC 集群名称`\
-rp oracle `# 主机 root 用户密码`\
-gp oracle `# 主机 grid 用户密码`\
-op oracle `# 主机 oracle 用户密码`\
-lf eth0 `# 主机网卡名称`\
-pf eth1 `# 主机心跳网卡名称`\
-ri 192.168.6.180,192.168.6.181 `# RAC 公网 IP`\
-vi 192.168.6.182,192.168.6.183 `# RAC 虚拟 IP`\
-si 192.168.6.184 `# RAC SCAN IP`\
-od /dev/sdb `# OCR 磁盘盘符名称`\
-dd /dev/sdc `# DATA 磁盘盘符名称`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-opd Y `# 是否优化数据库`
```

### 3 节点安装（支持 N 节点安装，目前已测试过 5 节点）
```bash
./OracleShellInstall -n oel `# RAC 主机名前缀`\
-hn oel01,oel02 `# RAC 主机名`\
-cn oel-cls `# RAC 集群名称`\
-rp oracle `# 主机 root 用户密码`\
-gp oracle `# 主机 grid 用户密码`\
-op oracle `# 主机 oracle 用户密码`\
-lf eth0 `# 主机网卡名称`\
-pf eth1 `# 主机心跳网卡名称`\
-ri 192.168.6.180,192.168.6.181,192.168.6.182 `# RAC 公网 IP`\
-vi 192.168.6.183,192.168.6.184,192.168.6.185 `# RAC 虚拟 IP`\
-si 192.168.6.184 `# RAC SCAN IP`\
-od /dev/sdb `# OCR 磁盘盘符名称`\
-dd /dev/sdc `# DATA 磁盘盘符名称`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-gpa 35940989 `# grid PSU/RU 补丁编号`\
-jpa 35926646 `# OJVM PSU/RU 补丁编号`\
-opd Y `# 是否优化数据库`
```

### 生产环境安装
```bash
./OracleShellInstall -n oel `# RAC 主机名前缀`\
-hn oel01,oel02 `# RAC 主机名`\
-cn oel-cls `# RAC 集群名称`\
-sn luciferdb-scan `# SCAN 名称`\
-rp 'Passw0rd#PST' `# 主机 root 用户密码`\
-gp 'Passw0rd#PST' `# 主机 grid 用户密码`\
-op 'Passw0rd#PST' `# 主机 oracle 用户密码`\
-lf bond0 `# 主机网卡名称`\
-pf eth1,eth2 `# 主机心跳网卡名称`\
-ri 192.168.6.180,192.168.6.181 `# RAC 公网 IP`\
-vi 192.168.6.182,192.168.6.183 `# RAC 虚拟 IP`\
-si 192.168.6.184,192.168.6.185,192.168.6.186 `# RAC SCAN IP`\
-dns Y `# 是否配置 DNS`\
-dnsn lucifer.dns.com `# DNS 域名`\
-dnsi 192.168.6.188 `# DNS IP`\
-tsi 192.168.6.190 `# 时间服务器 IP`\
-od /dev/sdb,/dev/sdc,/dev/sdd `# OCR 磁盘盘符名称`\
-or NORMAL `# OCR 磁盘组冗余度`\
-on OCR `# OCR 磁盘组名称`\
-dd /dev/sde `# DATA 磁盘盘符名称`\
-dr EXTERNAL `# DATA 磁盘组冗余度`\
-dn DATA `# DATA 磁盘组名称`\
-ad /dev/sdf `# ARCH 磁盘盘符名称`\
-ar EXTERNAL `# ARCH 磁盘组冗余度`\
-an ARCH `# ARCH 磁盘组名称`\
-o lucifer `# 数据库名称`\
-dp 'Passw0rd#PST' `# sys/system 用户密码`\
-ds AL32UTF8 `# 数据库字符集`\
-ns AL16UTF16 `# 国家字符集`\
-redo 1000 `# 在线重做日志大小（M）`\
-gpa 35940989 `# grid PSU/RU 补丁编号`\
-jpa 35926646 `# OJVM PSU/RU 补丁编号`\
-opd Y `# 是否优化数据库`
```