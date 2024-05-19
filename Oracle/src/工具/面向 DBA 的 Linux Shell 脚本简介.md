# 面向 DBA 的 Linux Shell 脚本简介

## 说明

了解如何通过基本 bash shell 脚本在 Linux 上安装、运行和维护 Oracle 数据库。

大约七年前，Oracle 发布了首个基于 Linux 的商业数据库。从那时起，Oracle、Red Hat 和 Novell/SUSE 就不断地合作更改 Linux 内核，从而提高数据库和应用程序的性能。正因为这样，面向 Linux 的 Oracle 数据库 10g 包含了许多与操作系统密切相关的增强功能。数据库管理员 (DBA) 比以往任何时候都更需要该平台的知识和经验来监视并更好地管理系统。

以往，系统管理员与 DBA 之间在职责方面存在差别。但实际上，这种差别通常并不明显。许多 IT 部门雇用可解决数据库层和操作系统层问题的员工。当然，Oracle 数据库本身使用操作系统资源，并能与其环境紧密交互。

此外，许多系统管理员和 DBA 认为将工作相关的任务自动化很有必要或比较方便。软件安装、系统资源监视以及系统管理涉及一些重复且容易出错的任务，而自动过程可以比手动过程更好地完成这些任务。

要将这些任务自动化，其中一个方法是使用 shell 脚本。Shell 脚本自 Linux 系统安装之初就起着重要作用。系统启动和关闭时就会调用各种脚本。Oracle 和其他第三方供应商的实用程序也是通过 shell 脚本调用的。由于这些脚本可以快速开发，因此历来都用它们来构建应用程序原型。系统管理员利用通过 shell 脚本实现的功能，针对其监视的系统的特定要求和特征提供定制的解决方案。

在本文中，我将介绍“bash”shell 脚本可以实现的、与在 Linux 平台上安装、运行和维护 Oracle 数据库相关的功能。请注意，本文适用于 Linux 脚本初学者或对 Linux 相对陌生的 DBA；对大多数经验丰富的 Linux 系统管理员则不适用。

什么是 shell 脚本？

shell 脚本是一个包含命令序列的文本文件。当运行文件或脚本时，将执行该文件中包含的命令。术语 shell 仅指与 Linux 内核通信所使用的特定命令行用户界面。目前有多个不同的 shell，其中包括 C shell (csh)、Korn shell (ksh)、Bourne shell (sh) 和 Bourne-Again shell (bash)。shell 本身是一个从文件或终端读取命令、解释这些命令并通常执行其他命令的命令。Bourne-Again shell 合并了上述其他 shell 的特性，本文将使用该脚本进行演示。

脚本文件中的第一行可用于指定使用哪个 shell 来运行该脚本。以下是所有脚本示例中第一行的含义：

~~~shell
#!/bin/bash
~~~

为什么使用 shell 脚本？

由于 shell 脚本与 DBA 的工作相关，因此您可能不会马上看到 shell 脚本的价值，这跟您的工作经历有关。如果您以前从未使用过 UNIX 或类似 UNIX 的系统，可能会对大量含义晦涩的命令感到一愁莫展。此外，除了作为关系数据库外，Oracle 10g 还提供了一个用于处理数据库数据的强大平台以及几个用于在数据库外部与操作系统交互的方法。

您探究 shell 脚本领域可能有几种动因，其中包括：

- 您必须支持现有的脚本。
- 您需要在安装 Oracle 软件之前自动设置系统。例如，您可以编写一个脚本来检查 OS 的初始状态并报告安装软件前必须满足的任何前提条件。该脚本还可以创建相关的 OS 用户和组，并为用户设置环境变量。
- 您可以使用正在运行的 Oracle 数据库来执行手动或计划的任务。但是，您需要在数据库*未*运行时运行某些任务。您可以使用脚本停止或启动数据库（以及侦听器或相关的数据库进程）。此类动作无法从数据库内部启动。
- 您需要一种监视数据库状态（例如，是否正在运行并可进行进程查询）的机制。这样的脚本还可以监视非特定于 Oracle 的其他进程和资源，从而提供系统当前运行情况的更详细信息。
- 您需要实现备份自动化。Oracle Recovery Manager (RMAN) 是一个实用程序，可用于开发可以在任何平台上运行的备份脚本。您可以从 shell 脚本中调用 Oracle Recovery Manager 并使用它执行各种备份和恢复活动。
- 您可能具有非特定于某个数据库的要求。您可能在一台计算机上安装了多个数据库。我们建议您不要使用单个数据库满足此要求，因为那样会引发潜在的安全性问题。在这种情况下，shell 脚本提供了一种既可以满足此要求，又不会将进程与单个数据库关联的方法。

什么情况下不适合使用 shell 脚本？

Oracle 数据库包含了超出 RDBMS 传统定义的功能。与软件的任何其他部分一样，Oracle 数据库使用操作系统提供的资源，但它所能“看到”并“更改”环境的程度远远超过了其他软件。SQL 和 Oracle 的固定视图从数据库内部提供了系统视图，而 shell 脚本从数据库外部提供了系统视图。shell 脚本并不是适用于所有问题的解决方案。

我们必须意识到，操作系统的许多方面都可以从数据库内部进行监视和修改。您可以使用 Oracle 的固定视图（带 v$ 前缀的视图）确定计算机的主机名 (v$instance) 或数据库所在的运行平台的名称 (v$database)。您还可以通过此方式确定与数据库关联的文件的位置和其他属性。您可以直接从数据库查询数据文件 (v$datafile，dba_data_files)、临时文件 (v$tempfile，dba_temp_files)、重做日志 (v$logfile)、存档日志 (v$archived_log) 和控制文件 (v$controlfile) 的位置和其他属性。您可以从该视图以及通过查看某些 init.ora 参数 (db_recovery_file_dest、db_recovery_file_dest_size) 来确定有关闪回恢复区 ($recovery_file_dest) 的信息。您还可以查询进程 (v$process) 和内存（v$sga、v$sgastat 等）的状态。您可以使用各种内置的 PL/SQL 程序包，创建允许对底层 OS 进行其他访问的 Java 和 C 数据库对象。

如果您正在考虑为一个需要大量数据库访问的任务编写脚本，则脚本可能并不是理想的选择。本文的稍后部分将介绍如何使用 SQL*Plus 访问数据库，但在很多情况下，使用其他语言可以更好地解决此问题。

下表归纳了可以从数据库中访问的信息：

## 服务器/操作系统信息

| 服务器标识             | 典型查询                                      | 附注>                                                        |
| :--------------------- | :-------------------------------------------- | :----------------------------------------------------------- |
| 实例运行所在的主机名称 | select host_name from v$instance;             | 您还可以通过从 bash 运行以下命令来获取此信息：`hostname`或`uname -n` |
| 操作系统平台           | select platform_name from v$database; --(10g) | 如果运行 uname -s，则将返回类似的信息                        |

## 文件信息

| Oracle 文件位置                    | 典型查询                                                     | 附注                                                         |
| :--------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 控制文件                           | select name from v$controlfile;                              | 数据库控制文件的位置。init.ora 参数 control_files 也包含此信息。 |
| 数据文件                           | select file_name from Dba_data_files;                        | 数据库数据文件的位置                                         |
| 临时文件                           | select file_name from Dba_temp_files;                        | 数据库临时文件的位置                                         |
| 日志文件                           | select member from v$logfile;                                | 重做日志的位置                                               |
| 存档日志                           | select name from v$archived_log;                             | 存档重做日志的位置。init.ora 参数 log_archive_dest_n 也包含此信息。如果数据库不在 Archivelog 模式下，则该查询将不返回结果。 |
| 闪回恢复区                         | select name from v$recovery_file_dest;                       | Oracle 10g 安装用作闪回恢复区的目录。init.ora 参数 db_recovery_file_dest 也包含此信息。 |
| 由参数指示的文件系统上的其他访问点 | select * from  v$parameter where value like '%/%' or value like '%/%'; | 根据 Oracle 数据库安装和版本的不同，该查询的结果可能迥然不同。可能返回的参数有：<br/>spfile<br>standby_archive_dest<br/>utl_file_dir<br/>background_dump_dest<br/>user_dump_dest<br/>core_dump_dest<br/>audit_file_dest<br/>dg_broker_config_file1<br/>dg_broker_config_file2 |
| 以编程方式访问文件系统             | select directory_path from dba_directories;                  | 可以使用 Oracle UTL_FILE_DIR 参数和 DIRECTORY 数据库对象访问标准数据库功能以外的文件。 |



## 进程信息

| 处理器/进程        | 典型查询                                                     | 附注                                                         |
| :----------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 会话进程           | select p.spid, s.username, s.program from v$process p, v$session s where p.addr=s.paddr order by 2, 3, 1; | 可以将 spid 与 ps -ef 结果相关联，以将数据库中的可用信息与给定进程的操作系统信息进行比较。 |
| 与并行性相关的流程 | select slave_name, status from v$PQ_SLAVE;                   | Oracle 数据库的很多方面（如加载、查询、对象创建、恢复和复制）都可以利用并行来加快可以分割的活动。参数 parallel_threads_per_cpu 设置实例的默认并行度。 |

## 内存信息

| 内存       | 典型查询                 | 附注                                                         |
| :--------- | :----------------------- | :----------------------------------------------------------- |
| 程序全局区 | select * from V$PGASTAT; | pga_aggregate_target 参数用于为所有专用服务器连接配置内存。可以使用 vmstat 和 top 等 Linux 实用程序监视内存使用情况。 |
| 系统全局区 | select * from v$sga;     | SGA_MAX_SIZE 和 SGA_TARGET 参数用于配置 Oracle 数据库 10 g 的动态内存分配特性。其他参数可用于为特定用途手动分配内存。同时，各种 Linux 实用程序可用于监视内存分配。 |







BASH 脚本

脚本可以作为自动化流程的一部分调用（无需人为干预），也可以以交互方式运行（用户根据提示执行操作）。只要您拥有文件的执行权限，便可以从命令行键入该文件的名称来运行它。如果您没有该文件的执行权限，但拥有读取权限，则可以通过在脚本的前面加上 sh 来运行该脚本。

如果脚本设计为在无用户输入的情况下运行，则可以使用多种可选方法调用它。您可以在后台运行脚本，即使在断开连接的情况下，也仍可以通过输入以下形式的命令来运行：

~~~shell
nohup /path_to_dir/myscript_here.sh &
~~~

这对于需要很长时间才能完成的脚本很有用。at 命令可用于在将来执行脚本，而 cron 可用于计划要重复执行的脚本。

以下示例介绍了提供视图输出（使用 echo）、循环、条件逻辑以及变量赋值等重要方面。

## 脚本结构示例

### print_args.sh

参数是位于命令名右侧并传递到脚本中的单词。要访问第一个参数，请使用 $1 变量。$0 变量包含脚本本身的名称。$# 变量包含脚本中的参数个数。一种通过迭代传递所有参数的便捷方法是使用 while 循环和 shift 命令。此命令允许您迭代参数列表中的所有参数（而非保持无限循环）。

~~~shell
while [ $# -ne 0  ]
do
        echo $1
        shift
done
~~~

如果要脚本将文件名作为参数（或提示用户输入文件名）并在后面读取该文件，我们建议您检查其访问性和可读性。例如，涉及选择备份控制文件的恢复脚本可能提示用户选择将在脚本后面部分中用于恢复文件的备份控制文件。

~~~shell
if [ ! -r $1 ]; then # not exists and is readable
                        echo "File $1 does not exist or is not readable."
                exit;
fi
~~~

字符序列

~~~shell
if [ ! -r $1 ];
~~~

是实际执行测试的部分。如果方括号之间的内容结果为 true，则将执行位于 if 和 fi 之间的命令。实际测试显示在方括号之间。感叹号用于对所执行的测试取反。`-r` 选项检查文件是否可读。在这个特定示例中所要测试的是传递给脚本的第一个参数。通过使用另一测试 (`-d`)，您可以检查给定条目是否是目录（请参见 is_a_directory.sh）。

### do_continue.sh

该示例是一个可用于读取各种目的的用户输入的简单、典型的命令序列。在运行可能在某些无法从脚本内部确定的条件下导致数据丢失或其他不好结果的进程前，建议您增加一个提示，询问用户是否确实希望脚本执行接下来的命令。以下示例询问用户是否要继续，从命令行读取一个名为 doContinue 的变量并对求解用户的输入。如果用户输入的不是“y”，则告知该用户脚本将“退出”且不执行 if 代码块 (fi) 后的其他脚本。

~~~shell
doContinue=n
echo -n "Do you really want to continue? (y/n) " 
read doContinue

if [ "$doContinue" != "y" ]; then
      echo "Quitting..."
      exit
fi
~~~

只有拥有相应权限和环境的用户,才能运行给定脚本。脚本有一个有用的检查，可对试图运行该脚本的用户进行检查。如果将命令括在单引号 (‘) 字符中，则将该命令的结果返回给脚本。以下示例在脚本中使用 whoami 检索当前登录的用户，并稍后使用 date 命令显示日期。

~~~shell
echo "You are logged in as ‘whoami‘";

if [ ‘whoami‘ != "oracle" ]; then
  echo "Must be logged on as oracle to run this script."
  exit
fi

echo "Running script at ‘date‘"
~~~

为与 Oracle 数据库交互而编写的脚本有时需要输入敏感信息，如数据库密码。stty –echo 命令关闭屏幕响应，这样为随后的读取命令输入的信息就不会显示在屏幕上了。在读取机密信息并将其存储在变量（以下示例中的 pw）中后可以使用 stty echo 重新打开显示。

~~~shell
stty -echo    
        echo -n "Enter the database system password:  "
        read pw
stty echo
~~~

### get_inv_location.sh

Oracle 脚本

某些文件位于给定 Oracle 安装的固定位置。您可以通过查看 /etc/oraInst.loc 文件获得 Oracle 清单。/etc/oratab 文件标识服务器上安装的数据库（和其他 Oracle 程序）。

该脚本不如前面的示例直观。通过将该脚本划分为几组命令，您将更好的理解该脚本的构成。

要确定清单位置，您可以把 cat 命令（显示文件的内容）的结果输送到 grep（一个打印匹配给定模式的行的实用程序）。您将搜索包含文字 `inventory_loc.` 的行。

~~~shell
cat /etc/oraInst.loc | grep inventory_loc
~~~

如果因有多个安装而导致存在多个清单位置，则需要排除用 # 注释掉的行。–v 选项排除包含给定模式的行。

~~~shell
cat /etc/oraInst.loc |grep -v "#"|grep inventory_loc
~~~

此命令的结果如下所示：

~~~shell
inventory_loc=/u01/oraInventory
~~~

您可以使用 > 重定向命令将标准输出重定向到一个文件。如果该文件不存在，则会创建该文件。如果该文件已存在，则将其覆盖。

~~~shell
cat /etc/oraInst.loc|grep -v "#"|grep inventory_loc > tmp
~~~

一旦获得表明信息库位置的记录后，您就要删除该记录等号前的部分。这次，您将 cat 命令的结果输送到 awk（一种通常用于拆分可变长度字段的模式扫描和处理语言），这实际上是将字符串标记化。–F 选项指示 awk 将等号用作分隔符。然后，打印该字符串的第二个标记 ($2)，它代表等号右侧的所有内容。其结果是我们要找的清单位置 (/u01/oraInventory)。

~~~shell
cat tmp | awk -F= '{print $2}'
~~~

由于没有必要保留临时文件 (tmp)，因此可以将它删除。

~~~shell
rm tmp
~~~

### list_oracle_homes.sh

如果要确定给定数据库的 ORACLE_HOME，则有多个可选方法。您可以以数据库用户身份登录，并对 $ORACLE_HOME 变量执行 echo。您还可以搜索 /etc/oratab 文件并选择与给定实例关联的名称。该文件中的数据库条目的形式如下：

~~~shell
$ORACLE_SID:$ORACLE_HOME:<N|Y>:
~~~

以下单行代码输出条目（ORACLE_SID 为 TESTDB）的 ORACLE_HOME：

~~~shell
cat /etc/oratab | awk -F: '{if ($1=="TESTDB") print $2 }'
~~~

但如果您需要对 /etc/orainst 文件中列出的每个 ORACLE_HOME 执行操作，该怎么办？您可以使用以下代码段迭代这样的列表。

~~~shell
dblist=`cat /etc/oratab | grep -v "#" | awk -F: '{print $2 }'`

for ohome in $dblist ; do
  echo $ohome
done
~~~

dblist 变量被用作数组。所有 ORACLE_HOME 路径均由该变量保存。for 循环用于迭代此列表，并将每个条目分配给变量 ohome，然后将其发送到标准输出。

### search_log.sh

Oracle 产品生成各种日志，您可能要监视它们。数据库警报日志包含对数据库操作至关重要的消息。当安装或卸载产品以及在应用补丁时，也会生成日志文件。以下脚本迭代以参数形式传递给它的文件。如果发现任何包含 ORA- 的行，则向指定的接收者发送电子邮件。

~~~shell
cat $1 | grep ORA- > alert.err

if [ `cat alert.err|wc -l` -gt 0 ]
then
        mail -s "$0 $1 Errors" administrator@yourcompany.com < alert.err
fi
~~~

执行的具体测试是统计文件 alert.err（在您重定向到 alert.err 时写入）中存在的单词数。如果单词数 (wc) 大于 (-gt) 零，则执行 if 代码块。这该示例中，您使用 mail（也可以使用 send mail）发送邮件。邮件标题包含所执行的脚本 ($0)、搜索的日志名称 ($1)，邮件正文是与初始搜索 (ORA-) 匹配的行。

您可以使用 ORACLE_HOME、ORACLE_BASE 和 ORACLE_SID 等环境变量来查找不在 Linux 环境中固定位置的资源。如果您要管理 Oracle E-Business Suite 11i 应用程序实例，则可以使用许多其他环境变量来定位资源。这些变量包括 APPL_TOP、TWO_TASK、CONTEXT_NAME 和 CONTEXT_FILE 等。要查看您环境中的完整列表，请执行以下命令并检查生成的文件 (myenv.txt)：

~~~shell
env > myenv.txt
~~~

您可以将这些环境变量的各种组合用作所搜索文件的位置。例如，您可以将警报日志位置指定为

~~~shell
$ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log
~~~

根据该脚本中引入的原则，您可以编写一个更大的脚本并计划定期执行，该脚本将搜索警报日志（或其他所关注的文件）的内容并在发生任何错误时发送电子邮件。然后，您可以将日志内容移动到其他文件，确保电子邮件只发送最新的错误消息。

### Oracle Recovery Manager 脚本

Oracle Recovery Manager (RMAN) 是一个可用于管理数据库备份和恢复的实用程序。由于编写的所有备份脚本都可以由 RMAN 运行，即减少了平台特定的代码数量，因此它明显简化了多个平台的管理。RMAN 可由底层操作系统调用并接受传递来的脚本。例如，冷 (cold.sh) 备份可能由以下脚本组成：

~~~shell
#!/bin/bash
rman target / <<EOF
shutdown immediate;
startup mount;
backup spfile;
backup database;
alter database open;
delete noprompt obsolete;
quit;
EOF
~~~

第 1 行表明您正在使用 bash shell。第 2 行调用 Oracle Recovery Manager 并指定 OS 用户登录目标数据库（在环境变量 $ORACLE_SID 中指定）。该行后面的 <<EOF 表示将把随后的命令传递到 RMAN 中去处理。最后一行上的 EOF 表示您已经到了要传递到 RMAN 中的命令序列的结尾。然后，使用 RMAN 关闭数据库、启动并安装数据库并继续备份服务器参数文件和数据库的内容。接着，打开数据库。删除比保留策略中指定的备份旧的任何备份。请参见 RMAN 文档，构建与您的情况相关的备份。

晚间备份通常按计划自动运行。您可以使用以下命令调用以上脚本，并将标准输出的内容发送到电子邮件地址：

~~~shell
sh cold.sh | mail -s"Backup `date`" administrator@yourcompany.com
~~~

同样地，您可以从 shell 脚本内部运行其他 Oracle 实用程序。您可以使用 tnsping 实用程序查看给定 Oracle 连接标识符能否连接监听程序。您可以运行该实用程序来检查连接问题：

~~~shell
tnsping ptch04 |grep TNS-
~~~

数据库导出和导入（传统的和数据泵）比较适合于编写重复进程脚本。

### 数据库安装

数据库设置中涉及的许多步骤都可以实现自动化。在 Linux 上安装 Oracle 10*g* 之前，需要运行各种测试来验证所需的最低程序包版本和内核参数的设置。您可以使用带 `–q` 选项的 `rpm` 命令查询程序包的版本。

~~~shell
rpm -q compat-libstdc++
~~~

您可以通过查看 /proc“虚拟”或“伪”文件系统确定系统的各个方面。但它不包含实际的文件，而是包含可以查看的运行时系统信息（就好像位于文件中一样）。例如，/proc/meminfo 包含系统的内存信息，而 grep MemTotal /proc/meminfo 显示系统的总内存。如前所述，通过使用 awk，您可以使用以下方法分割内存量（以千字节为单位）：

~~~shell
grep MemTotal /proc/meminfo | awk '{print $2}'
~~~

您可以在进行相应的比较和响应（甚至更新系统本身）的脚本上下文中使用这样的命令。示例脚本 10gchecks_kernel.sh 和 10gchecks.sh 只显示基于 Oracle 文档的当前和建议的版本和设置。

### 数据库监视

ps 命令可用于报告进程状态以及检查数据库、监听程序、脚本或任何其他相关进程是否正在运行。如果要列出服务器上当前运行的所有数据库，则运行以下命令：

~~~shell
echo "`ps -ef | grep smon|grep -v grep|awk '{print $8}'| awk -F \"_\" '{print$3}'`"
~~~

虽然这是功能性的，但一开始就很难理解。第一个命令 ps（使用 -ef 选项获取所有进程的完整列表）查找在服务器上运行的所有进程。接下来，第二个命令 grep 将搜索 SMON（Oracle System Monitor 后台进程），这表示数据库正在运行。您要删除引用正在运行的 grep 命令的条目。然后，使用 awk 找到列表中的第八列，其中包含 ora_smon_<oracle_sid> 形式的系统监视器进程名称。然后，awk 的最后一个实例使用下划线字符作为分隔符来搜索并打印拥有此 SMON 进程的数据库名称。下划线字符需要括在引号中，并在每个引号之前使用一个反斜杠将这些引号转义（因为整个字符串显示在一组双引号中）。

### exec_sql.sh

如前所述，只要用户有权访问 sqlplus，就可以从 shell 脚本中查询数据库。以下示例返回当前在数据库中保持会话状态的计算机列表（由空格分隔）：

~~~shell
#!/bin/bash

output=`sqlplus -s "/ as sysdba" <<EOF
       set heading off feedback off verify off
       select distinct machine from v\\$session;
       exit
EOF
`

echo $output
~~~

由于您将命令输入到其他程序中，因此该脚本类似于前一个 RMAN 脚本。您可以以 sysdba 的身份与数据库建立一个经验证的本地 OS 连接。为防止返回不必要的消息，该脚本关闭 `SQL*Plus` 的 heading、feedback 和 verify 选项。执行查询并退出 SQL*Plus。

注意视图名称中 $ 之前的双反斜杠。它们是字符串中所需的转义序列：第一个反斜杠转义，第二个反斜杠，后者转义 $。尽管并不好看，但却很实用。

如前所述，如果要编写需要广泛数据库访问权限的代码，那么 shell 脚本并不是理想的选择。使用 PL/SQL、Perl（使用类似于 shell 脚本中使用的语法）、Python、Java 或随便其他什么语言重写脚本，效果可能会更好。

# 参考连接

https://www.oracle.com/cn/technical-resources/articles/linux/saternos-scripting.html

https://www.oracle.com/technetwork/cn/articles/saternos-scripting-092818-zhs.html
