https://blog.csdn.net/weixin_52341477/article/details/127740632

HOME：用户的家目录；
HOSTNAME：服务器的主机名；
SHELL：用户当前使用的Shell解析器；
HISTSIZE：保存历史命令的数目；
USER：当前登录用户的用户名；
PWD：当前工作目录；
PYTHONPATH：Python导入包的路径，内容是以冒号分隔的路径列表；
C_INCLUDE_PATH：C语言的头文件路径，内容是以冒号分隔的路径列表；
CPLUS_INCLUDE_PATH：CPP的头文件路径，内容是以冒号分隔的路径列表；
LD_LIBRARY_PATH：用于指定动态链接库(.so文件)的路径，其内容是以冒号分隔的路径列表，非系统默认；
PATH：可执行文件（命令）的存储路径。路径与路径之间用:分隔。当某个可执行文件同时出现在多个路径中时，会选择从左到右数第一个路径中的执行；
JAVA_HOME：jdk的安装目录；
CLASSPATH：存放Java导入类的路径，内容是以冒号分隔的路径列表，非系统默认；
LANG：LANG环境变量存放的是Linux系统的语言、地区、字符集，它不需要系统管理员手工设置，/etc/profile会调用/etc/profile.d/lang.sh脚本完成对LANG的设置。

zh_CN.UTF-8
en_US.UTF-8

# 语言变量
export LANG="zh_CN.UTF-8"
export LANG="en_US.UTF-8"

echo 'LANG=en_US.UTF-8' >> ~/.bash_profile
source ~/.bash_profile