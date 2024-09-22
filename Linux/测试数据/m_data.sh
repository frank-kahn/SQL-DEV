#!/bin/bash
# DATE:2021-2-7 20:14
# VERSION: V1.0
# BY:多哥
# 随机造数据。数据字段包括:cus_id cus_name cus_date cus_loc cus_hp(handphone number)

#删除上一次执行该脚本时产生的数据文件
rm -rf m_data.dat 

#指定要产生数据的行数，这个由你自己定义
read -p '请输入您想造数据的行数：' x

#美国的五十个州 做地理数据用
loc=(Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois Indiana Iowa Kansas Kentucky Lousiana Maine Maryland Massachusetts Michigan Minnesot Mississippi Missouri Montana Nebraska Nevada 'New Hampshire' 'New Jersey' 'New Mexico' 'New York' 'North Carolin' 'North Dakota' Ohio Oklahoma Oregon Pennsylvania 'Rhode Island' 'South Carolin' 'South Dakota' Tennessee Texas Utah Vermont Virginia Washington 'West Virginia' Wisconsin Wyoming)

#主业务程序开始
for i in `seq 1 $x` 
do

c=$[RANDOM%51]
a=`head /dev/urandom | tr -dc 4-8 | head -c 1`

echo $i\
','\
"'`head /dev/urandom | tr -dc a-z | head -c $a`'"\
','\
"'`date -d "-$[RANDOM%365] day -$[RANDOM%24] hour" "+%Y-%m-%d %H:%M:%S"`'"\
','\
"'${loc[$c]}'"\
','\
'1'`tr -cd '0-9' </dev/urandom | head -c 10`
done >> m_data.dat
