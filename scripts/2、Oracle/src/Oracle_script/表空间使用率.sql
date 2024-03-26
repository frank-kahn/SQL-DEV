select upper(f.tablespace_name) "��ռ���",
       ����d.tot_grootte_mb "��ռ��С(M)",
              d.tot_datafile_mb "��ռ��ļ����ֵ(G)",
       ����d.tot_grootte_mb - f.total_bytes "��ʹ�ÿռ�(M)",
       ����to_char(round((d.tot_grootte_mb - f.total_bytes) /
              d.tot_grootte_mb * 100,2), '999.99') || '%' "ʹ�ñ�",
       ����f.total_bytes "���пռ�(M)",
       ����f.max_bytes "����(M)"
  from (select tablespace_name,
           round(sum(bytes) / (1024 * 1024), 2) total_bytes,
           round(max(bytes) / (1024 * 1024), 2) max_bytes
          from sys.dba_free_space
         group by tablespace_name) f,
       ���� (select dd.tablespace_name,
                  round(sum(dd.bytes) / (1024 * 1024), 2) tot_grootte_mb,
                  round(sum(decode(dd.maxbytes, 0, dd.bytes, dd.maxbytes)) /
                        (1024 * 1024 * 1024),
                        2) tot_datafile_mb
             from sys.dba_data_files dd
            group by dd.tablespace_name) d
 where d.tablespace_name = f.tablespace_name
 order by 1;
