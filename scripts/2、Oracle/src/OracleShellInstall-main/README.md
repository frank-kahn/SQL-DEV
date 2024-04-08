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
	- 增加功能：在欧拉 openEuler 22.03 国产系统安装单机版 Oracle 11GR2，12CR2，19C 版本
- `2024/03/21`
	- 增加功能：在欧拉 openEuler 22.03 国产系统安装 Oracle 19C RAC
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

# 目前确定不支持列表
- 龙蜥 Anolis7.9 版本不支持安装 12CR2/19C/21C，无法解决，建库报错：[FATAL] [DBT-05509] Failed to connect to the specified database 和 ORA-12547: TNS:lost contact
- RHEL9/OEL9/CENTOS9 版本不支持安装 11GR2,12CR2，官方没有认证
- RHEL8/OEL8/CENTOS8 版本不支持安装 11GR2 RAC Grid，官方只认证单机
- RHEL6/OEL6/CENTOS6 版本不支持安装 19C，21C，官方没有认证
- 麒麟 Kylin V10 版本不支持安装 11GR2 RAC Grid，同 RHEL8/OEL8/CENTOS8

# 实操参考
- [Redhat 8.4 一键安装 Oracle 11GR2 单机版](https://www.modb.pro/db/627155)
- [11GR2 rac 2节点一键安装演示](https://www.modb.pro/db/1767103571552702464)
- [11GR2 rac 5节点一键安装演示](https://www.modb.pro/db/626761)
- [Redhat 9.3 一键安装 Oracle 19C 19.21 单机版](https://www.modb.pro/db/1722500845915430912)
- [19C 19.22 RAC 2节点一键安装演示](https://www.modb.pro/db/1767425920041848832)
- [openEuler 22.03（华为欧拉）一键安装 Oracle 11G（231017）单机版](https://www.modb.pro/db/1769591803778535424)
- [openEuler 22.03（华为欧拉）一键安装 Oracle 12CR2（220118）数据库](https://www.modb.pro/db/1772864352247451648)
- [openEuler 22.03（华为欧拉）一键安装 Oracle 19C（19.22） 数据库](https://www.modb.pro/db/1769539674624823296)
- [openEuler 22.03（华为欧拉）一键安装 Oracle 19C RAC（19.22） 数据库](https://www.modb.pro/db/1770329115010338816)
- [麒麟 V10 一键安装 Oracle 11GR2（231017）单机版](https://www.modb.pro/db/1762008192972820480)
- [麒麟 V10 一键安装 Oracle 12CR2（220118）单机版](https://www.modb.pro/db/1773265001669824512)
- [麒麟 V10 一键安装 Oracle 19C 19.22 单机版](https://www.modb.pro/db/1761982554933587968)
- [龙蜥 Anolis OS 7.9 一键安装 Oracle 11GR2（231017）单机版](https://www.modb.pro/db/1772081728022188032)
- [龙蜥 Anolis OS 7.9 一键安装 Oracle 12CR2（220118）单机版【失败，OS 不支持】](https://www.modb.pro/db/1772845918450159616)
- [龙蜥 Anolis OS 7.9 一键安装 Oracle 19C（19.22）单机版【失败，OS 不支持】](https://www.modb.pro/db/1772105823525900288)
- [龙蜥 Anolis OS 8.8 一键安装 Oracle 11GR2（231017）单机版](https://www.modb.pro/db/1772131084879368192)
- [龙蜥 Anolis OS 8.8 一键安装 Oracle 12CR2（220118）单机版](https://www.modb.pro/db/1772858229067943936)
- [龙蜥 Anolis OS 8.8 一键安装 Oracle 19C（19.22）单机版](https://www.modb.pro/db/1772107172300820480)
- [SUSE 15 SP5 一键安装 Oracle 11GR2（231017）单机版](https://www.modb.pro/db/1773547168497995776)
- [SUSE 15 SP5 一键安装 Oracle 12CR2（220118）单机版](https://www.modb.pro/db/1772860821603979264)
- [SUSE 15 SP5 一键安装 Oracle 19C（19.22）单机版](https://www.modb.pro/db/1772452639086809088)
- [统信 UOS V20 一键安装 Oracle 11GR2（231017）单机版](https://www.modb.pro/db/1773552274713972736)
- [统信 UOS V20 一键安装 Oracle 12CR2（220118）单机版](https://www.modb.pro/db/1773270182230855680)
- [统信 UOS V20 一键安装 Oracle 19C（19.22）单机版](https://www.modb.pro/db/1773564096011669504)

# 脚本介绍
继第二代更新一年左右，Oracle 一键安装脚本第三代强势登场了，脚本代码全部重构，优化逻辑，加快执行速度，全程无人工干预安装，支持不限节点安装，全部汉化。

- 重构超过 80% 代码，提升执行效率
- 重写以及增删部分参数，脚本更加智能化
- 重写脚本帮助（-h）功能，提高用户可读性
- 重写代码注释，更方便用户读懂脚本，参与共创
- 重写互信脚本，提高稳定性以及速度
- 重写脚本日志输出功能
- 重写脚本打印功能，保证打印内容整齐美观
- 优化安装过程输出显示（每一步执行提示，去除解压等无效输出）
- 重写脚本参数判断功能
- 重写安装数据库后优化功能

# 参数介绍
关于脚本的参数使用可执行 `./OracleShellInstall -h` 进行查看。
## Single 参数
单实例数据库仅需 `-lf` 参数即可安装：`./OracleShellInstall`，详细参数可参考如下表格。

| 参数缩写 | 参数用途                                                     | 参数默认值 | 是否必填 |
| -------- | ------------------------------------------------------------ | :--------: | :------: |
| -iso     | 是否需要配置本地 YUM 镜像源（需提前挂载 ISO）<br> ☆ 如需使用网络 YUM 源或云主机自带 YUM 源，请配置为 `-iso N` 即可 |     Y      |    ×     |
| -lf      | 公网 IP 网卡名称（需自行配置网络）<br> ☆ 主机 IP 地址需要自行配置，通过网卡名称自动识别本机 IP 地址 |            |    √     |
| -n       | 主机名<br> ☆ 如不填写该参数，默认主机名为 orcl               |    orcl    |    ×     |
| -op      | 系统 oracle 用户密码                                         |   oracle   |    ×     |
| -d       | 安装 Oracle 软件根目录                                       |    /u01    |    ×     |
| -ord     | 存放 Oracle 数据文件目录                                     |  /oradata  |    ×     |
| -o       | 数据库名称<br> ☆ 数据库名称（db_name），实例名称（instance_name），服务名称（service_names） |    orcl    |    ×     |
| -dp      | 数据库 sys/system 用户密码                                   |   oracle   |    ×     |
| -ds      | 数据库字符集                                                 |  AL32UTF8  |    ×     |
| -ns      | 国家字符集                                                   |    AL16UTF16    |    ×     |
| -er      | 是否开启归档模式                                             |    true    |    ×     |
| -pdb     | pdb名称<br> ☆ 11GR2 以上版本一但配置该参数，则默认数据库安装为 CDB 架构 |   pdb01    |    ×     |
| -redo    | 在线重做日志初始大小 <br> ☆ 默认单位为 MB                    |    1024    |    ×     |
| -opa     | Oracle DB 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33803476_190000_Linux-x86-64.zip，只需要设置 `-opa 33803476` 即可 |            |    ×     |
| -jpa     | Oracle JVM 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33808367_190000_Linux-x86-64.zip，只需要设置 `-jpa 33808367` 即可 |            |    ×     |
| -m       | 仅配置操作系统 <br> ☆ 一般用于需要图形化安装时，一键配置操作系统，一般与 `-gui` 参数配置使用 |     N      |    ×     |
| -ud      | 安装至数据库软件完成 <br> ☆ 顾名思义，只安装至 Oracle 软件，不创建数据库，一般可用于 DG，恢复演练等场景 |     N      |    ×     |
| -gui     | 是否安装图形化界面                                           |     N      |    ×     |
| -opd     | 安装后是否优化数据库 <br> ☆ 包括配置数据库开机自启，定时备份脚本，glogin 配置，大页配置，参数优化配置 |     N      |    ×     |

## Standalone 参数
单实例 ASM 数据库仅需 `-lf` 和 `-dd` 参数即可安装：`./OracleShellInstall`，详细参数可参考如下表格。

| 参数缩写 | 参数用途                                                     | 参数默认值 | 是否必填 |
| -------- | ------------------------------------------------------------ | :--------: | :------: |
| -iso     | 是否需要配置本地 YUM 镜像源（需提前挂载 ISO）<br> ☆ 如需使用网络 YUM 源或云主机自带 YUM 源，请配置为 `-iso N` 即可 |     Y      |    ×     |
| -lf      | 公网 IP 网卡名称（需自行配置网络）<br> ☆ 主机 IP 地址需要自行配置，通过网卡名称自动识别本机 IP 地址 |            |    √     |
| -n       | 主机名<br> ☆ 如不填写该参数，默认主机名为 orcl               |    orcl    |    ×     |
| -op      | 系统 oracle 用户密码                                         |   oracle   |    ×     |
| -d       | 安装 Oracle 软件根目录                                       |    /u01    |    ×     |
| -ord     | 存放 Oracle 数据文件目录                                     |  /oradata  |    ×     |
| -o       | 数据库名称<br> ☆ 数据库名称（db_name），实例名称（instance_name），服务名称（service_names） |    orcl    |    ×     |
| -gp      | 系统 grid 用户密码                                           |          oracle           |    ×     |
| -dp      | 数据库 sys/system 用户密码                                   |   oracle   |    ×     |
| -adc     | 是否配置 asm 磁盘（多路径+udev）<br> ☆ 默认脚本配置<br> ☆ 如不需要脚本配置，则传参 `-adc N`，需要人为在执行脚本前提前配置好 asm 磁盘<br> ☆ 对应的 `-dd` 参数传入配置好的 asm 磁盘路径，例如：`-dd /dev/asm_data_1` |             Y             |    x     |
| -mp      | 是否需要配置多路径<br> ☆ 本脚本强制配置 udev <br> ☆ 默认脚本配置 multipath 多路径，如不需要配置多路径，则配置该参数 `-mp N` |             Y             |    ×     |
| -am      | 配置 asm 磁盘的方式<br> ☆ 有 `udev` 和 `asmlib` 选项         |           udev            |    x     |
| -dd      | DATA 磁盘设备原始名称<br> ☆支持多块磁盘（无上限），以逗号隔开：`-od /dev/sda,/dev/sdb,/dev/sdc` |                           |    √     |
| -dn      | DATA 磁盘组名称                                              |           DATA            |    ×     |
| -dr      | DATA 磁盘组冗余模式                                          |         EXTERNAL          |    ×     |
| -ds      | 数据库字符集                                                 |  AL32UTF8  |    ×     |
| -ns      | 国家字符集                                                   |    AL16UTF16    |    ×     |
| -er      | 是否开启归档模式                                             |    true    |    ×     |
| -pdb     | pdb名称<br> ☆ 11GR2 以上版本一但配置该参数，则默认数据库安装为 CDB 架构 |   pdb01    |    ×     |
| -redo    | 在线重做日志初始大小 <br> ☆ 默认单位为 MB                    |    1024    |    ×     |
| -gpa     | Grid 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33803476_190000_Linux-x86-64.zip，只需要设置 `-gpa 33803476` 即可 |                           |    ×     |
| -opa     | Oracle DB 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33803476_190000_Linux-x86-64.zip，只需要设置 `-opa 33803476` 即可 |            |    ×     |
| -jpa     | Oracle JVM 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33808367_190000_Linux-x86-64.zip，只需要设置 `-jpa 33808367` 即可 |            |    ×     |
| -m       | 仅配置操作系统 <br> ☆ 一般用于需要图形化安装时，一键配置操作系统，一般与 `-gui` 参数配置使用 |     N      |    ×     |
| -ud      | 安装至数据库软件完成 <br> ☆ 顾名思义，只安装至 Oracle 软件，不创建数据库，一般可用于 DG，恢复演练等场景 |     N      |    ×     |
| -gui     | 是否安装图形化界面                                           |     N      |    ×     |
| -opd     | 安装后是否优化数据库 <br> ☆ 包括配置数据库开机自启，定时备份脚本，glogin 配置，大页配置，参数优化配置 |     N      |    ×     |
| -vbox    | 用于修复在 virtualbox 虚拟机安装 rac bug                     |             N             |    ×     |
| -fd      | 过滤多路径磁盘，去除重复路径，获取唯一盘符；参数值为非ASM盘符（系统盘等），例如：-fd /dev/sda，多个盘符用逗号拼接：-fd /dev/sda,/dev/sdb ||×|

## RAC 参数
RAC 数据库可支持无限节点安装。

| 参数缩写 | 参数用途                                                     |        参数默认值         | 是否必填 |
| -------- | ------------------------------------------------------------ | :-----------------------: | :------: |
| -iso     | 是否需要配置本地 YUM 镜像源（rac 所有节点均需提前挂载 ISO）<br> ☆ 如需使用网络 YUM 源或云主机自带 YUM 源，请配置为 `-iso N` 即可 |             Y             |    ×     |
| -lf      | 公网 IP 网卡名称（需自行配置网络）<br> ☆ 主机 IP 地址需要自行配置，通过网卡名称自动识别本机 IP 地址 |                           |    √     |
| -pf      | rac 心跳IP 网卡名称（需自行配置网络）<br> ☆ 主机 IP 地址需要自行配置<br> ☆ 两个节点IP网卡名称需要对应并保持一致<br> ☆ 最多支持 2 组心跳，以逗号隔开：`-pf eth0,eth1` |                           |    √     |
| -n       | rac 所有节点主机名的前缀<br> ☆ 该参数可用于配置集群名称和 scan 名称 |           orcl            |    √     |
| -hn      | rac 所有节点的主机名<br> ☆ 以逗号隔开：`-hn orcl01,orcl02`<br> ☆ 参数值必须要严格按照节点顺序以逗号隔开 |                           |    √     |
| -ri      | rac 所有节点 IP 地址（需自行配置网络）<br> ☆ 主机 IP 地址需要自行配置<br> ☆ 以逗号隔开：`-ri 10.211.55.100,10.211.55.101`<br> ☆ 参数值必须要严格按照节点顺序以逗号隔开 |                           |    √     |
| -vi      | rac 所有节点 Virtual IP 地址（需提前规划好，避免 IP 冲突）<br> ☆ 主机 IP 地址需要自行配置<br> ☆ 以逗号隔开：`-vi 10.211.55.102,10.211.55.103`<br> ☆参数值必须要严格按照节点顺序以逗号隔开 |                           |    √     |
| -si      | rac scan IP 地址（需提前规划好，避免 IP 冲突）<br> ☆ 如需配置多组 scan ip，必须要配合 DNS 参数 `-dns,-dnsn,-dnsi` 使用，否则不支持<br> ☆ 最多支持 3 组 scan ip，以逗号隔开：`-si 10.211.55.105,10.211.55.106,10.211.55.107` |                           |    √     |
| -d       | 安装 Grid/Oracle 软件根目录                                  |           /u01            |    ×     |
| -rp      | 系统 root 用户密码<br> ☆ rac 所有节点 root 用户密码必须保持一致 |                           |    √     |
| -gp      | 系统 grid 用户密码                                           |          oracle           |    ×     |
| -op      | 系统 oracle 用户密码                                         |          oracle           |    ×     |
| -cn      | rac 集群名称<br> ☆ 优先级高于 `-n` 参数<br> ☆ 集群名称不可超过 15 位，否则安装失败<br> ☆ 如不配置该参数和 `-n` 参数，默认为 `orcl-cluster`<br> ☆ 如不配置该参数，配置 `-n lucifer`，默认为 `lucifer-cluster`，此时 `-n` 参数主机名前缀不可超过 7 位，否则安装失败<br> ☆ 如配置该参数，则不受 `-n` 参数限制 | 主机名前缀加上 `-cluster` |    ×     |
| -sn      | rac scan 名称<br> ☆ 优先级高于 `-n` 参数<br> ☆如不配置该参数和 `-n` 参数，默认为 `orcl-scan`<br> ☆ 如不配置该参数，配置 `-n lucifer`，默认为 `lucifer-scan`<br> ☆ 如配置该参数，则不受 `-n` 参数限制 |  主机名前缀加上 `-scan`   |    ×     |
| -adc     | 是否配置 asm 磁盘（多路径+udev）<br> ☆ 默认脚本配置<br> ☆ 如不需要脚本配置，则传参 `-adc N`，需要人为在执行脚本前提前配置好 asm 磁盘<br> ☆ 对应的 `-od,-dd,-ad` 参数传入配置好的 asm 磁盘路径，例如：`-od /dev/asm_ocr_1`,`-dd /dev/asm_data_1` |             Y             |    x     |
| -mp      | 是否需要配置多路径<br> ☆ 本脚本强制配置 udev <br> ☆ 默认脚本配置 multipath 多路径，如不需要配置多路径，则配置该参数 `-mp N` |             Y             |    ×     |
| -am      | 配置 asm 磁盘的方式<br> ☆ 有 `udev` 和 `asmlib` 选项         |           udev            |    x     |
| -od      | OCR/Voting 磁盘设备原始名称<br> ☆支持多块磁盘（无上限），以逗号隔开：`-od /dev/sda,/dev/sdb,/dev/sdc` |                           |    √     |
| -dd      | DATA 磁盘设备原始名称<br> ☆支持多块磁盘（无上限），以逗号隔开：`-od /dev/sda,/dev/sdb,/dev/sdc` |                           |    √     |
| -ad      | ARCH 磁盘设备原始名称<br> ☆支持多块磁盘（无上限），以逗号隔开：`-od /dev/sda,/dev/sdb,/dev/sdc` |                           |    ×     |
| -on      | OCR/Voting 磁盘组名称                                        |            OCR            |    ×     |
| -dn      | DATA 磁盘组名称                                              |           DATA            |    ×     |
| -an      | 归档磁盘组名称                                               |           ARCH            |    ×     |
| -or      | OCR/Voting 磁盘组冗余模式                                    |         EXTERNAL          |    ×     |
| -dr      | DATA 磁盘组冗余模式                                          |         EXTERNAL          |    ×     |
| -ar      | ARCH 磁盘组冗余模式                                          |         EXTERNAL          |    ×     |
| -o       | 数据库名称<br> ☆ 数据库名称（db_name）<br> ☆ 以默认 `orcl` 为例，实例名称（instance_name）和服务名称（service_names）自行拆分为 `orcl1/orcl2` |           orcl            |    ×     |
| -dp      | 数据库 sys/system 用户密码                                   |          oracle           |    ×     |
| -ds      | 数据库字符集                                                 |         AL32UTF8          |    ×     |
| -ns      | 国家字符集                                                   |           AL16UTF16            |    ×     |
| -er      | 是否开启归档模式                                             |           true            |    ×     |
| -pdb     | pdb名称<br> ☆ 11GR2 以上版本一但配置该参数，则默认数据库安装为 CDB 架构 |           pdb01           |    ×     |
| -redo    | 在线重做日志初始大小 <br> ☆ 默认单位为 MB                    |           1024            |    ×     |
| -tsi     | 时间服务器 IP 地址<br> ☆ 用于配置 rac 所有节点间的时间同步，通过定时任务的方式执行 |                           |    ×     |
| -dns     | 是否配置 DNS<br> ☆ 一般与 `-si` 参数配合使用，如果 scan ip 超过 1 个，则必须配置 DNS 参数 |             N             |    ×     |
| -dnsn    | DNS 服务器名称                                               |                           |    ×     |
| -dnsi    | DNS 服务器 IP 地址                                           |                           |    ×     |
| -gpa     | Grid 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33803476_190000_Linux-x86-64.zip，只需要设置 `-gpa 33803476` 即可 |                           |    ×     |
| -jpa     | Oracle JVM 补丁，仅支持 PSU/RU 补丁<br> ☆ 填写补丁号即可，例如补丁 p33808367_190000_Linux-x86-64.zip，只需要设置 `-jpa 33808367` 即可 |                           |    ×     |
| -m       | 仅配置操作系统 <br> ☆ 一般用于需要图形化安装时，一键配置操作系统，一般与 `-gui` 参数配置使用 |             N             |    ×     |
| -ug      | 安装至 Gird 软件完成 <br> ☆ 顾名思义，只安装至 Grid 软件，一般可用于集群测试，DBUA 升级等场景 |             N             |    ×     |
| -ud      | 安装至数据库软件完成 <br> ☆ 顾名思义，只安装至 Oracle 软件，不创建数据库，一般可用于 DG，恢复演练等场景 |             N             |    ×     |
| -gui     | 是否安装图形化界面                                           |             N             |    ×     |
| -opd     | 安装后是否优化数据库 <br> ☆ 包括配置数据库开机自启，定时备份脚本，glogin 配置，大页配置，参数优化配置 |             N             |    ×     |
| -vbox    | 用于修复在 virtualbox 虚拟机安装 rac bug                     |             N             |    ×     |
| -fd      | 过滤多路径磁盘，去除重复路径，获取唯一盘符；参数值为非ASM盘符（系统盘等），例如：-fd /dev/sda，多个盘符用逗号拼接：-fd /dev/sda,/dev/sdb ||×|

# 脚本使用
使用脚本前：
- 安装好干净的 Linux 操作系统（redhat/oracle linux/centos）
- 配置好网络（规划 IP 地址）
- 配置好存储（规划存储）
- 挂载 ISO 镜像源
- 上传必须安装包软件

以下提供常用安装命令，可根据实际情况进行增删。
## Single 安装
### 最简化测试环境部署
仅需上传 Oracle 基础安装包即可：
```bash
./OracleShellInstall -lf eth0 `# local ip ifname`
```

### 生产环境安装部署
需要上传 Oracle 基础安装包和补丁包（Opatch以及PSU/RU）：
```bash
./OracleShellInstall -lf enp0s5 `# local ip ifname`\
-n lucifer `# hostname`\
-op oracle `# oracle password`\
-d /u01 `# software base dir`\
-ord /oradata `# data dir`\
-o oradb `# dbname`\
-dp oracle `# sys/system password`\
-ds AL32UTF8 `# database character`\
-ns UTF8 `# national character`\
-redo 1024 `# redo size`\
-opa 33806152 `# oracle PSU/RU`\
-jpa 33808367 `# OJVM PSU/RU`\
-opd Y `# optimize db`
```

## Standalone 安装
### 最简化测试环境部署
上传 Oracle 安装包：
```bash
./OracleShellInstall -lf eth0 `# local ip ifname`\
-dd /dev/sde,/dev/sdf `# asm data disk`
```

### 生产环境安装部署
需要上传 Oracle 基础安装包和补丁包（Opatch以及PSU/RU）：
```bash
./OracleShellInstall -lf ens192 `# local ip ifname`\
-n lucifer `# hostname`\
-op oracle `# oracle password`\
-d /u01 `# software base dir`\
-ord /oradata `# data dir`\
-o oradb `# dbname`\
-dp oracle `# sys/system password`\
-ds AL32UTF8 `# database character`\
-ns UTF8 `# national character`\
-redo 100 `# redo size`\
-dd /dev/sde,/dev/sdf `# asm data disk`\
-gpa 31718723 `# Grid PSU/RU`\
-jpa 31668908 `# OJVM PSU/RU`\
-opd Y `# optimize db`
```

## RAC 安装
最简化测试环境部署：
```bash
./OracleShellInstall -n lucifer `# hostname prefix`\
-rp oracle `# root password`\
-lf eth0 `# local ip ifname`\
-pf eth1 `# rac private ip ifname`\
-ri 10.211.55.100,10.211.55.101 `# rac public ip`\
-vi 10.211.55.102,10.211.55.103 `# rac virtual ip`\
-si 10.211.55.105 `# rac scan ip`\
-od /dev/sdb `# rac ocr asm disk`\
-dd /dev/sdc `# rac data asm disk`
```

### 生产环境安装部署
需要上传 Oracle 基础安装包和补丁包（Opatch以及PSU/RU）：

#### 2 节点安装
```bash
./OracleShellInstall -n luciferdb `# hostname prefix`\
-hn luciferdb03,luciferdb04 `# rac node hostname`\
-cn luciferdb-cls `# cluster_name`\
-rp oracle `# root password`\
-gp oracle `# grid password`\
-op oracle `# oracle password`\
-lf team0 `# local ip ifname`\
-pf eth3,eth4 `# rac private ip ifname`\
-ri 10.211.55.100,10.211.55.101 `# rac node public ip`\
-vi 10.211.55.102,10.211.55.103 `# rac virtual ip`\
-si 10.211.55.104,10.211.55.105,10.211.55.106 `# rac scan ip`\
-od /dev/sdg `# rac ocr asm disk`\
-dd /dev/sdc,/dev/sdd,/dev/sde,/dev/sdf `# rac data asm disk`\
-o oradb `# dbname`\
-ds AL32UTF8 `# database character`\
-ns AL16UTF16 `# national character`\
-dp oracle `# sys/system password`\
-tsi 10.211.55.150 `# timeserver ip`\
-dns Y -dnsn orcl.lucifer.com -dnsi 10.211.55.200 `# DNS INFO`\
-gpa 32226491 `# grid PSU/RU`\
-jpa 33808367 `# OJVM PSU/RU`\
-opd Y `# optimize db`
```

#### 3 节点安装
```bash
./OracleShellInstall -n luciferdb `# hostname prefix`\
-hn luciferdb03,luciferdb04,luciferdb05 `# rac node hostname`\
-cn luciferdb-cls `# cluster_name`\
-rp password `# root password`\
-gp oracle `# grid password`\
-op oracle `# oracle password`\
-lf eth0 `# local ip ifname`\
-pf eth1 `# rac private ip ifname`\
-ri 193.1.3.1,193.1.3.2,193.1.3.3 `# rac node public ip`\
-vi 193.1.3.4,193.1.3.5,193.1.3.6 `# rac virtual ip`\
-si 193.1.3.10 `# rac scan ip`\
-od /dev/sdb `# rac ocr asm disk`\
-dd /dev/sdc `# rac data asm disk`\
-o oradb `# dbname`\
-ds AL32UTF8 `# database character`\
-ns AL16UTF16 `# national character`\
-dp Oracle123Pwd `# sys/system password`\
-gpa 31718723 `# grid PSU/RU`\
-jpa 31668908 `# OJVM PSU/RU`\
-opd Y `# optimize db`
```

#### 5 节点安装
```bash
./OracleShellInstall -n luciferdb `# hostname prefix`\
-hn luciferdb01,luciferdb02,luciferdb03,luciferdb04,luciferdb05 `# rac node hostname`\
-cn luciferdb-cls `# cluster_name`\
-sn luciferdb-scan `# scan_name`\
-rp oracle `# root password`\
-gp oracle `# grid password`\
-op oracle `# oracle password`\
-lf ens192 `# local ip ifname`\
-pf ens224,ens256 `# rac private ip ifname`\
-ri 192.168.6.31,192.168.6.32,192.168.6.33,192.168.6.34,192.168.6.35 `# rac node public ip`\
-vi 192.168.6.51,192.168.6.52,192.168.6.53,192.168.6.54,192.168.6.55 `# rac virtual ip`\
-si 192.168.6.50 `# rac scan ip`\
-tsi 202.112.10.36 `# timeserver ip`\
-od /dev/sdb,/dev/sdc,/dev/sdd `# rac ocr asm disk`\
-dd /dev/sde,/dev/sdf `# rac data asm disk`\
-o oradb `# dbname`\
-ds AL32UTF8 `# database character`\
-ns AL16UTF16 `# national character`\
-dp oracle `# sys/system password`\
-redo 50 `# redo size`\
-gpa 31718723 `# grid PSU/RU`\
-jpa 31668908 `# OJVM PSU/RU`\
-opd Y `# optimize db`
```

支持 N 节点安装，只需要增加对应的主机名和IP地址即可！