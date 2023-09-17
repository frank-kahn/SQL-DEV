mysql -uroot -N -e "select * from performance_schema.session_status where variable_name in ('Connections','Max_used_connections','Max_used_connections_time');"
