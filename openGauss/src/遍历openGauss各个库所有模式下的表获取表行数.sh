#!/bin/bash
db_name="postgres"
db_port="12345"
env_path=" /home/omm/env"
#echo "查询所有的库"
sql=" SELECT datname FROM pg_database where datname!='template1' and datname!='template0';"
all_db=$(source ${env_path};gsql -d ${db_name} -p ${db_port} -At -c "${sql}")
#echo "遍历所有的库，查询每个库的表"
sql="SELECT nspname || '.' || relname FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema' AND nspname != 'dbe_perf' AND C.relkind <> 'i' AND nspname !~ '^pg_toast' AND nspname != 'dbe_pldeveloper' and nspname != 'db4ai';"
for db in ${all_db[@]}
	do
	 #echo "当前库 :${db}"	 
	  all_table=`gsql -d ${db} -p ${db_port} -At -c "${sql}"`
	  for table in ${all_table[@]}
	  do
	  source${env_path}
	  echo "${db}.${table}:`gsql -d $db -p ${db_port} -p ${db_port} -At -c "select count(*) from $table;"`"
	done
done
