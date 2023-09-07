rman target / catalog rman/rman@rman msglog '/backup/logs/itpux_fghsdb_rman_delete_arch.log' << EOF
run
{
crosscheck archivelog all;
delete noprompt archivelog until time "sysdate-10";
delete noprompt expired archivelog all;
}
exit;
EOF
