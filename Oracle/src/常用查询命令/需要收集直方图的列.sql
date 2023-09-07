--需要收集直方图的列
select a.owner,
       a.table_name,
       a.column_name,
       b.NUM_ROWS,
       a.num_distinct Cardinality,
       round(a.num_distinct / b.NUM_ROWS * 100, 2) selectivity
  from dba_tab_col_statistics a, dba_tables b
 where a.owner = b.OWNER
   and a.table_name = b.TABLE_NAME
   and a.owner = 'HIPCQ'
   and round(a.num_distinct / b.NUM_ROWS * 100, 2) < 5
   and num_rows > 50000
   and (a.table_name, a.column_name) in
       (select o.name, c.name
          from sys.col_usage$ u, sys.obj$ o, sys.col$ c, sys.user$ r
         where o.obj# = u.obj#
           and c.obj# = u.obj#
           and c.col# = u.intcol#
           and r.name = 'HIPCQ')
