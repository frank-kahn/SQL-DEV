#conda查看安装源
conda config --show
#添加源
conda config --add channels <parameters>
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
#删除源
conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
# 设置搜索时显示通道地址
conda config --set show_channel_urls yes


#检查安装的库
conda list
#更新conda
conda update conda
#更新三方所有的包
conda upgrade --all


#打开网页程序界面
jupyter notebook
#升级pip
pip install -U
python -m pip install --upgrade pip
#使用pip安装
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
#设置默认安装源
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

#国内常用源
https://mirror.tuna.tsinghua.edu.cn/help/pypi/



#查看当前所有的虚拟环境
conda env list
#创建虚拟环境
conda create -n $* python=3.6
#激活虚拟环境
activate $*
#退出虚拟环境
deactivate
#删除虚拟环境
conda remove --all -n $*





https://gist.github.com/seanlook/4faf374283400f907bebe29ffbfa74ac
简单写了个脚本，根据Navicat导出的格式，生成EC目前在测试和开发环境所有MySQL实例的连接地址。 使用者只需要将当前目录下 connections.ncx 和 vgroup.xml 放到navicat适当目录下，即可获得所有地址信息，不需要再逐个手动添加



import pymysql
from collections import defaultdict

"""
This script is used to generate Navicat connections list to save your time adding many MySQL connection info to Navicat GUI.
output: (in current directory)
- connections.ncx: import it to navicat
- vgroup.xml: move it to navicat Profile location, usually C:\Users\ecuser\Documents\Navicat\Premium\profiles
db instances login user and password shall be provided by your self.
ablog.mysql.info:
CREATE TABLE `mysql_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `environment` varchar(20) DEFAULT NULL,
  `dbid` varchar(30) DEFAULT NULL,
  `dbhost` varchar(100) DEFAULT NULL,
  `dbport` int(11) DEFAULT '3306',
  `dbgroup` varchar(20) DEFAULT NULL,
  `dbcluster` varchar(20) DEFAULT NULL,
  `conn_name` varchar(60) DEFAULT NULL,
  `dbuser` varchar(30) DEFAULT NULL,
  `dbpass` varchar(120) DEFAULT NULL,
  `hostname` varchar(60) DEFAULT NULL,
  `description` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4;
"""

dbconn = pymysql.Connect(host='192.168.1.125', port=3307, user='xx', password='xxx', charset='utf8', database='ablog')

sql = """
SELECT * FROM mysql_info
"""

cur = dbconn.cursor()
cur.execute(sql)
instances = cur.fetchall()

navicat_connections = []
navicat_vgroup = defaultdict(list)
tmpl_connection = """
<Connection ConnectionName="{0}" ConnType="MYSQL" OraConnType="BASIC" 
Host="{1}" Port="{2}" Database="" OraServiceNameType="SERVICENAME" TNS="" MSSQLAuthenMode="SQLSERVER" DatabaseFileName="" 
UserName="{3}" Password="{4}" SavePassword="true" SettingsSavePath="C:\Users\Administrator\Documents\Navicat\MySQL\servers\{0}" 
Encoding="65001" Keepalive="false" KeepaliveInterval="240" MySQLCharacterSet="true" Compression="false" AutoConnect="false" NamedPipe="false" NamedPipeSocket="/tmp/mysql.sock" OraRole="DEFAULT" OraOSAuthen="false" SQLiteEncryption="false" MSSQLEncryption="false" UseAdvanced="false" SSL="false" SSL_Authen="false" SSL_PGSSLMode="REQUIRE" SSL_ClientKey="" SSL_ClientCert="" SSL_CACert="" SSL_Clpher="" SSL_PGSSLCRL="" SSH="false" SSH_Host="" SSH_Port="22" SSH_UserName="" SSH_AuthenMethod="PASSWORD" SSH_Password="" SSH_SavePassword="false" SSH_PrivateKey="" HTTP="false" HTTP_URL="" HTTP_EQ="false" HTTP_PA="false" HTTP_PA_UserName="" HTTP_PA_Password="" HTTP_PA_SavePassword="false" HTTP_CA="false" HTTP_CA_ClientKey="" HTTP_CA_ClientCert="" HTTP_CA_CACert="" HTTP_CA_Passphrase="" HTTP_Proxy="false" HTTP_Proxy_Host="" HTTP_Proxy_Port="0" HTTP_Proxy_UserName="" HTTP_Proxy_Password="" HTTP_Proxy_SavePassword="false"/>
"""

for row in instances:
    conn_name = row[7]
    db_host = row[3]
    db_port = row[4]
    db_user = row[8]
    db_pass_x = row[9]
    navicat_vgroup[row[1]].append(conn_name)
    navicat_connections.append(tmpl_connection.format(conn_name, db_host, db_port, db_user, db_pass_x))



tmpl_vgroup = '\n<Category Name="{0}" Type="Connection">'
tmpl_vgroup_item = '<Item Name="{0}" Type="Connection" ServerType="ctMYSQL"/>'
navicat_group = []
for conn_group, conn_names in navicat_vgroup.items():
    navicat_group.append(tmpl_vgroup.format(conn_group))
    for conn_name in conn_names:
        navicat_group.append(tmpl_vgroup_item.format(conn_name))
    navicat_group.append('</Category>')


with open("connections.ncx", 'w') as f1, open('vgroup.xml', 'w') as f2:
    f1.write('<?xml version="1.0" encoding="UTF-8"?>\n<Connections Ver="1.1">\n')
    f1.write('\n'.join(navicat_connections))
    f1.write('\n</Connections>')


    f2.write('<?xml version="1.0" encoding="UTF-8"?>\n<VGroup Ver="1.1">\n')
    f2.write(''.join(navicat_group))
    f2.write('\n</VGroup>')

	