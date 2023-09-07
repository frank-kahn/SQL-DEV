rman target / catalog rman/rman@rman msglog '/backup/logs/itpux_fghsdb_rman_arch_backup.log' << EOF
run {
CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
allocate channel d1 type disk;

setlimit channel d1 kbytes 204800000 maxopenfiles 32 readrate 200; 

 
sql 'alter system archive log current';
backup tag itpux_db01_arch format '/backup/arch/itpux_fghsdb_full_%s_%p_%t' 
archivelog all delete all input;

release channel d1;

allocate channel d2 type disk;
	backup format '/backup/full/ctl_%s_%p_%t' current controlfile;
release channel d2;

allocate channel d3 type disk;
        copy current controlfile to '/backup/full/control_itpuxfghsdb.ctl';
release channel d3;
}

allocate channel for maintenance device type disk;
run
{
report obsolete;
delete noprompt expired backup;
delete noprompt expired copy;
delete noprompt obsolete device type disk;
}
exit
EOF


