#移动指定文件夹下的指定文件到当前目录
find ./ -name *.rpm -exec mv {} . \;
# 查找容量大于10G的文件 
find /data01 -type f -size +10G -exec ls -alh {} \; 
# 查找容量大于50G的目录 
find /data01 -type d -exec du -m {} \; > /tmp/dir_size.log
awk '{if ($1>50000) print $2,$1/1024}' /tmp/dir_size.log|sort -k 2,2nr|uniq
# 将当前文件夹下多级文件夹内的指定文件，移动到当前文件夹下
find ./ -name *.rpm -exec mv {} . \;