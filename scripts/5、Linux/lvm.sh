pvcreate /dev/sdb /dev/sdc /dev/sdd /dev/sde
vgcreate oravg /dev/sdb

lvcreate -n oralv -L 50000M oravg
lvcreate -n oralv -L 190G oravg

#格式化文件系统：
mkfs.xfs /dev/oravg/oralv
mkfs.ext4 /dev/oravg/oralv

echo "/dev/oravg/oralv		/oracle		xfs  defaults  0 0">>/etc/fstab

cat >> /etc/fstab << "EOF"
/dev/oravg/oralv /oracle ext4 defaults 0 0
EOF

cat /etc/fstab

pvs
vgs/vgdisplay
lvs/lvdisplay

mount -a
df -h


