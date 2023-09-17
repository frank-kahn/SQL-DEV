##echo "###rman配置###"
##su - oracle  -c"
rman target / << EOF
show all;
exit;
EOF
