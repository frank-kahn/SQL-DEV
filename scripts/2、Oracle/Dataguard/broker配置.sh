$ dgmgrl
#连接数据库
DGMGRL> connect sys/oracle@testdba
#查看数据信息
DGMGRL> show database verbose testdba;
#查看配置
DGMGRL> show configuration


#创建配置
DGMGRL> CREATE CONFIGURATION 'testdbabroker' as PRIMARY DATABASE IS 'testdba' CONNECT IDENTIFIER IS testdba;
#添加备库
DGMGRL> ADD DATABASE 'dgtestdba' as CONNECT IDENTIFIER IS dgtestdba;

#切换保护模式
DGMGRL> EDIT CONFIGURATION SET PROTECTION MODE AS MaxProtection;
DGMGRL> EDIT CONFIGURATION SET PROTECTION MODE AS MaxAvailability;
DGMGRL> EDIT CONFIGURATION SET PROTECTION MODE AS MaxPerformance;
DGMGRL> ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PROTECTION

#修改参数
DGMGRL> EDIT DATABASE testdba set Property LogXptMode='ASYNC';

#启动 observer
DGMGRL> start observer