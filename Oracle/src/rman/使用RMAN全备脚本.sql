/*
使用RMAN全备脚本
*/


--mkdir /oracle/rman
--chmod -R 777 /oracle/rman

--vi rman_full_itpux.sh

rman target / msglog '/oracle/rman.log' << EOF
crosscheck archivelog all;
run {
allocate channel c1 device type disk;
backup database tag itpux_full format '/oracle/rman/itpux_full_%s_p%t';
sql 'alter system archive log current';
backup archivelog all tag itpux_arch format '/oracle/rman/itpux_arch_%s_p%t';
backup current controlfile tag itpux_ctl format
'/oracle/rman/itpux_ctl_%s_p%t';
backup tag itpux_pfile format '/oracle/rman/itpux_pfile_%s_p%t'(spfile);
release channel c1;
}
EOF
exit
