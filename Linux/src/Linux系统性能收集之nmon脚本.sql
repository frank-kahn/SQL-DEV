/*
ÿ��22�����У�300���ռ�һ�Σ�288�� ��24*60*60/300=288
������ļ����浽 '/soft/nmon'Ŀ¼

ɾ��90��֮ǰ���ռ���Ϣ
*/
mkdir /soft/nmon
chmod -R 777 /soft/nmon
crontab -e
0 22 * * * nmon -f -s 300 -c 288 -m /soft/nmon > /dev/null 2>&1
0 23 * * * find /soft/nmon -name *.nmon -atime +90 -exec rm -rf {} \;
