#!/bin/bash
source ~/.bash_profile
backtime=$(date +"20%y%m%d%H%M%S")
rman target / log=/backup/level1_backup_$backtime.log<<-EOF
run {
allocate channel c1 device type disk;
allocate channel c2 device type disk;
crosscheck backup;
crosscheck archivelog all;
sql"alter system archive log current";
delete noprompt expired backup;
delete noprompt obsolete device type disk;
backup not backed up 1 times as compressed backupset archivelog all format '/backup/arch_%d_%T_%t_%s_%p';
backup incremental level 1 database include current controlfile format '/backup/backlv1_%d_%T_%t_%s_%p';
}
EOF