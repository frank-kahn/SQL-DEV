--5.0.0
https://opengauss.obs.cn-south-1.myhuaweicloud.com/5.0.0/x86/openGauss-5.0.0-CentOS-64bit-all.tar.gz


https://opengauss.obs.cn-south-1.myhuaweicloud.com/archive/2022/1230_youchu_303/x86/openGauss-3.0.3-CentOS-64bit-all.tar.gz
--master包
https://opengauss.obs.cn-south-1.myhuaweicloud.com/latest/x86/openGauss-3.1.1-CentOS-64bit-all.tar.gz
https://opengauss.obs.cn-south-1.myhuaweicloud.com/latest/x86/openGauss-5.0.0-CentOS-64bit-all.tar.gz


groupadd dbgrp
useradd -g dbgrp -d /home/omm -m -s /bin/bash omm
echo test@123|passwd --stdin omm


mkdir /data
cd /data
cat > one_node.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<ROOT>
    <!-- openGauss整体信息 -->
    <CLUSTER>
        <PARAM name="clusterName" value="dbCluster" />
        <PARAM name="nodeNames" value="testos2" />
        <PARAM name="gaussdbAppPath" value="/opengauss/app" />
        <PARAM name="gaussdbLogPath" value="/opengauss/log" />
        <PARAM name="tmpMppdbPath" value="/opengauss/tmp" />
        <PARAM name="gaussdbToolPath" value="/opengauss/om" />
        <PARAM name="corePath" value="/home/core" />
        <PARAM name="backIp1s" value="192.168.1.71"/>
       
    </CLUSTER>
    <!-- 每台服务器上的节点部署信息 -->
    <DEVICELIST>
        <!-- node1上的节点部署信息 -->
        <DEVICE sn="testos2">
            <PARAM name="name" value="testos2"/>
            <PARAM name="azName" value="AZ1"/>
            <PARAM name="azPriority" value="1"/>
            <!-- 如果服务器只有一个网卡可用，将backIP1和sshIP1配置成同一个IP -->
            <PARAM name="backIp1" value="192.168.1.71"/>
            <PARAM name="sshIp1" value="192.168.1.71"/>
            
	    <!--dbnode-->
	    <PARAM name="dataNum" value="1"/>
	    <PARAM name="dataPortBase" value="12345"/>
	    <PARAM name="dataNode1" value="/opengauss/data/dn"/>
            <PARAM name="dataNode1_syncNum" value="0"/>
        </DEVICE>
    </DEVICELIST>
</ROOT>
EOF

chown -R omm:dbgrp /data


lsof -i:12345


mkdir -p /software/unzip
cd /software
wget https://opengauss.obs.cn-south-1.myhuaweicloud.com/latest/x86/openGauss-3.1.0-CentOS-64bit-all.tar.gz
cd unzip
tar -zxvf ../openGauss-3.0.0-CentOS-64bit-all.tar.gz
tar -zxvf openGauss-3.0.0-CentOS-64bit-om.tar.gz


--预安装
cd /software/unzip/script/
./gs_preinstall -U omm -G dbgrp -X /data/one_node.xml --sep-env-file=/home/omm/env


--安装
su - omm
source /home/omm/env
gs_install -X /data/one_node.xml


cd
cat >.gsqlrc <<EOF
\set PROMPT1 '%n@%~%R%#'
\pset border 2
EOF

gs_guc reload -N all -I all -c "session_timeout = 86400s"
gs_om -t restart

gsql -p 12345 -d postgres -r



--卸载
su - omm
source /home/omm/env
gs_uninstall --delete-data

su - root
source /home/omm/env
source /home/omm/.bashrc
cd /software/unzip/script/
./gs_postuninstall -U omm -X /data/one_node.xml --delete-user --delete-group -L
unset MPPDB_ENV_SEPARATE_PATH














