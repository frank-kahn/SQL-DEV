/*
    Program:  check_ts_usage.sql
    Purpose:  Report the data that tablespace fall into lwm to admin
    History:
        Rev     Date        Author           Description
        -----   ----------  -------------    -----------------
        1.0     24-Jul-2022   norton.fan        Create the script 
*/

SET markup html ON spool ON entmap OFF


SET echo OFF
SET verify OFF
SET feedback OFF
SET termout OFF
SET pagesize 25
SET appinfo 'check_ts_usage.sql' 

COLUMN hostname         format a10    heading "HOSTNAME"
COLUMN instance_name    format a13    heading "INSTANCE_NAME"
COLUMN tablespace_name  format a15    heading "TABLESPACE_NAME"
COLUMN free_size        format 99,999 heading  "FREE_SIZE"
COLUMN work_time        format a13    heading "WORK_TIME"

spool /tmp/check_ts_usage.html


ttitle center "List the tablespace that fall into low water mark"  skip 2
 

SELECT t.*
  FROM (SELECT a.tablespace_name
              ,a.unalloc_size
              ,nvl(f.free_size, 0) free_size
              ,a.used_size - nvl(f.free_size, 0) used_size
              ,round((a.used_size - nvl(f.free_size, 0)) /
                     (a.unalloc_size + a.used_size)
                    ,2) capacity
          FROM (SELECT tablespace_name
                      ,round(SUM(bytes) / 1024 / 1024) free_size
                  FROM dba_free_space
                 GROUP BY tablespace_name) f
              ,(SELECT tablespace_name
                      ,round(SUM(user_bytes) / 1024 / 1024) used_size
                      ,round(SUM(decode(autoextensible
                                       ,'YES'
                                       ,decode(sign(maxbytes - user_bytes)
                                              ,-1
                                              ,0
                                              ,maxbytes - user_bytes)
                                       ,0)) / 1024 / 1024) unalloc_size
                  FROM dba_data_files
                 GROUP BY tablespace_name) a
         WHERE 1 = 1
           AND a.tablespace_name = f.tablespace_name(+)) t
 WHERE  capacity >= 0.85    ##阈值根据需要调整
   AND (unalloc_size + free_size) < 4000
   AND (unalloc_size + free_size) < used_size / 2
 ORDER BY capacity DESC;


SET markup html OFF
spool OFF
SET pagesize 14
ttitle OFF
SET feedback ON
SET termout ON
SET appinfo OFF
SET echo ON

EXIT