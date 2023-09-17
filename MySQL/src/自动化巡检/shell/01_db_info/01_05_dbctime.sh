mysql -uroot -N -e "select min(set_time) from sys.sys_config where set_by is NULL;"|grep -v "^-"
