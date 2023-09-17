mysql -uroot -N -e "select user,host,db,command,state from information_schema.processlist where command !='Sleep';"
