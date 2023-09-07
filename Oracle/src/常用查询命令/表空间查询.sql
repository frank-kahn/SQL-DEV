select a.tablespace_name, a.total1, b.free1, a.total1 - b.free1
  from (select tablespace_name,
        (sum(bytes)/ 1024 /1024) total1 from dba_data_files group by tablespace_name) a,
       (select tablespace_name,
         (sum(bytes)/1024/1024) free1 from dba_free_space group by tablespace_name) b where a.tablespace_name = b.tablespace_name
