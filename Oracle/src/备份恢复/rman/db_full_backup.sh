bakpath="/home/oracle/fullbak"
max_channel=8

#last_scn_sql=$bakpath/last_scn_$ORACLE_SID.sql
last_scn_spool=$bakpath/last_scn_$ORACLE_SID.spool
dbfile_list=$bakpath/dbfiles.list
rman_cmdfile=$bakpath/rman_cmdfile.cmd
rman_log=$bakpath/rman_log.log

#cp /dev/null $last_scn_sql
cp /dev/null $last_scn_spool
cp /dev/null $dbfile_list
cp /dev/null $rman_cmdfile
cp /dev/null $rman_log

#echo 'select bytes/1024,name from v\$datafile;' >> $last_scn_sql

sqlplus -s / as sysdba << EOF
set heading off feedback off echo off trimspool on pagesize 0 linesize 200
col scn for 999999999999
col bytes for 999999999999
col name for a150
spool $last_scn_spool
select min(checkpoint_change#) as scn from v\$datafile_header;
spool off
spool $dbfile_list
select bytes/1024 as bytes,name from v\$datafile;
spool off
exit
EOF

#############################  rman_cmdfile  begin #######################################
cat > $rman_cmdfile << EOF
configure controlfile autobackup on;
configure controlfile autobackup format for device type disk to '$bakpath/autobak_CF_%F';
run {
EOF
_loop=1
while [ $_loop -le $max_channel ]
do
echo "allocate channel c$_loop type disk format '$bakpath/fullbak_%U' maxpiecesize 32g;" >> $rman_cmdfile
((_loop++))
done
cat >> $rman_cmdfile << EOF
backup current controlfile format '$bakpath/temp_01_control.bak';
backup as compressed backupset full database;
backup current controlfile format '$bakpath/use_this_control.bak';
backup as compressed backupset archivelog from scn=$(cat $last_scn_spool) skip inaccessible;
backup current controlfile format '$bakpath/temp_02_control.bak';
}
configure controlfile autobackup off;
exit
EOF
#############################  rman_cmdfile  end #######################################

#后台执行备份
nohup rman target / nocatalog cmdfile $rman_cmdfile msglog $rman_log &