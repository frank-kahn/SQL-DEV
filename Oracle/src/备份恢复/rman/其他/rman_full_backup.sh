rman target / catalog rman/rman@rman msglog '/backup/logs/itpux_fghsdb_rman_full_backup.log' << EOF
run {
CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
allocate channel d1 type disk;
allocate channel d2 type disk;

setlimit channel d1 kbytes 204800000 maxopenfiles 32 readrate 200; 
setlimit channel d2 kbytes 204800000 maxopenfiles 32 readrate 200;
 
sql 'alter system archive log current';

backup
	incremental level 0
	skip inaccessible
	tag itpux_db01_level0
	filesperset 8 
	format '/backup/full/itpux_fghsdb_full_%s_%p_%t'
	(database);
release channel d1;
release channel d2;

allocate channel d3 type disk;
	backup format '/backup/full/ctl_%s_%p_%t' current controlfile;
release channel d3;

allocate channel d4 type disk;
        copy current controlfile to '/backup/full/control_itpuxfghsdb.ctl';
release channel d4;
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


