max_channel=8

if [[ -z  $ORACLE_SID ]]
then
echo "ORACLE_SID is not exist！！！"
exit
fi


echo 'set echo off heading off feedback off' > last_scn.sql
echo 'set pagesize 0 linesize 30' >> last_scn.sql
echo 'col min(checkpoint_change#) for 99999999999999999999' >> last_scn.sql
echo 'col fsize for 99999999999999999999' >> last_scn.sql
echo 'col name for a70' >> last_scn.sql
echo 'spool last_scn_$ORACLE_SID.spool' >> last_scn.sql
echo 'select min(checkpoint_change#) from v$datafile_header;' >> last_scn.sql
echo 'spool off' >> last_scn.sql
echo 'set pagesize 0 lines 200' >> last_scn.sql
echo 'spool df_$ORACLE_SID.list' >> last_scn.sql
echo 'select bytes/1024 fsize,name from v$datafile;' >> last_scn.sql
echo 'spool off' >> last_scn.sql
echo 'exit' >> last_scn.sql
sqlplus -s  / as sysdba @last_scn.sql




echo 'configure controlfile autobackup on;' > rman_cmdfile
echo "configure controlfile autobackup format for device type disk to '/home/oracle/backup/autobak_CF_%F';" >> rman_cmdfile
echo 'run {' >> rman_cmdfile

for i in `seq $max_channel`
do
echo "allocate channel c$i type disk format '/home/oracle/backup/fullbak_%U' maxpiecesize 32g;" >> rman_cmdfile
done

echo "backup current controlfile format '/home/oracle/backup/temp_01_control.bak';" >> rman_cmdfile
echo "backup as compressed backupset database;" >> rman_cmdfile
echo "backup current controlfile format '/home/oracle/backup/use_this_control.bak';" >> rman_cmdfile
echo "backup as compressed backupset archivelog from scn=`cat last_scn_$ORACLE_SID.spool` skip inaccessible;" >> rman_cmdfile
echo "backup current controlfile format '/home/oracle/backup/temp_03_control.bak';" >> rman_cmdfile
echo "}" >> rman_cmdfile
echo "configure controlfile autobackup off;" >> rman_cmdfile
echo "exit" >> rman_cmdfile



rman target / cmdfile rman_cmdfile msglog backup.log