#密码
opengauss
Huawei@123




<?xml version="1.0" encoding="UTF-8"?>
<ROOT>
    <!-- openGauss整体信息 -->
    <CLUSTER>
        <PARAM name="clusterName" value="oneNode" />
        <PARAM name="nodeNames" value="centos7" />
        <PARAM name="gaussdbAppPath" value="/opengauss/app" />
        <PARAM name="gaussdbLogPath" value="/opengauss/log" />
        <PARAM name="tmpMppdbPath" value="/opengauss/tmp" />
        <PARAM name="gaussdbToolPath" value="/opengauss/om" />
        <PARAM name="corePath" value="/home/core" />
        <PARAM name="backIp1s" value="192.168.1.65"/>
        <PARAM name="clusterType" value="AZ"/>

    </CLUSTER>
    <!-- 每台服务器上的节点部署信息 -->
    <DEVICELIST>
        <!-- node1上的节点部署信息 -->
        <DEVICE sn="centos7">
            <PARAM name="name" value="centos7"/>
            <PARAM name="azName" value="AZ1"/>
            <PARAM name="azPriority" value="1"/>
            <!-- 如果服务器只有一个网卡可用，将backIP1和sshIP1配置成同一个IP -->
            <PARAM name="backIp1" value="192.168.1.65"/>
            <PARAM name="sshIp1" value="192.168.1.65"/>

            <!--dbnode-->
            <PARAM name="dataNum" value="1"/>
            <PARAM name="dataPortBase" value="12345"/>
            <PARAM name="dataNode1" value="/opengauss/data/dn"/>
            <PARAM name="dataNode1_syncNum" value="0"/>
        </DEVICE>
    </DEVICELIST>
</ROOT>

python gs_preinstall -U omm -G dbgrp -X /opt/software/openGauss/clusterconfig.xml

gs_install -X /opt/software/openGauss/clusterconfig.xml --gsinit-parameter="--encoding=UTF8" --dn-guc="max_process_memory=4GB" --dn-guc="shared_buffers=256MB" --dn-guc="bulk_write_ring_size=256MB" --dn-guc="cstore_buffers=16MB"

