pvcreate /dev/sdb /dev/sdc /dev/sdd /dev/sde

vgcreate oravg /dev/sdb
vgcreate datavg /dev/sdc
vgcreate backup /dev/sdd
vgcreate archvg /dev/sde

lvcreate -n oralv -L 50000M oravg
lvcreate -n datalv -L 200000M datavg
lvcreate -n backuplv -L 400000M backup
lvcreate -n archivelv -L 200000 archvg

格式化文件系统：
mkfs.xfs /dev/backup/backuplv
mkfs.xfs /dev/archvg/archivelv
mkfs.xfs /dev/datavg/datalv
mkfs.xfs /dev/oravg/oralv

echo "/dev/oravg/oralv		/oracle		xfs  defaults  0 0">>/etc/fstab
echo "/dev/datavg/datalv	/oradata		xfs	defaults  0 0">>/etc/fstab
echo "/dev/backup/backuplv  /backup	xfs  defaults  0 0">>/etc/fstab
echo "/dev/archvg/archivelv  /archive	xfs  defaults  0 0">>/etc/fstab
echo "none /dev/shm   tmpfs defaults,size=6144m 0 0">>/etc/fstab

cat /etc/fstab
mkdir /oracle
mkdir /oradata
mkdir /backup
mkdir /archive


mount /oracle
mount /oradata
mount /backup
mount /archive
