--低选择性索引的语句
select c.sql_id,
c.sql_text,
b.index_name,
e.table_name,
trunc(d.num_distinct/e.NUM_ROWS*100,2) selectivity,
d.num_distinct,
e.NUM_ROWS 
from v$sql_plan a,
            (select *
               from (select index_owner,
                            index_name,
                            table_owner,
                            table_name,
                            column_name,
                            count(*) over(partition by index_owner, index_owner, index_name, table_owner, table_name) cnt
                       from dba_ind_columns)
              where cnt = 1) b,
              v$sql c,
            dba_tab_col_statistics d,
            dba_tables e
            where a.OBJECT_OWNER=b.index_owner
            and a.OBJECT_NAME=b.index_name
            and b.index_owner='HIPCQ'
            and a.ACCESS_PREDICATES is not null
            and a.SQL_ID=c.sql_id
            and a.CHILD_NUMBER=c.child_number
            and d.owner=e.owner
            and d.table_name=e.TABLE_NAME
            and b.table_owner=e.owner
            and b.table_name=e.TABLE_NAME
            and d.column_name=b.column_name
            and d.table_name=b.table_name
            and d.num_distinct/e.NUM_ROWS<0.1
