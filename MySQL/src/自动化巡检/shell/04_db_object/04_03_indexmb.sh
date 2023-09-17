mysql -uroot -N -e "select
table_schema as '数据库',
sum(truncate(data_length/1024/1024,2)) as '数据库容量(MB)'
from information_schema.tables
group by table_schema
order by sum(data_length) desc;"
