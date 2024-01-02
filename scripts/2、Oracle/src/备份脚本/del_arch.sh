#!/bin/bash
source ~/.bash_profile
deltime=$(date +"20%y%m%d%H%M%S")
rman target / nocatalog msglog /home/oracle/scripts/del_arch_$deltime.log <<-EOF
crosscheck archivelog all;
delete noprompt archivelog until time 'sysdate-7';
delete noprompt force archivelog until time 'SYSDATE-10';
EOF