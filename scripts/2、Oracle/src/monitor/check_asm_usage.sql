/*
    Program:  check_ASM_usage.sql
    Purpose:  Report the ASM usage
    History:
        Rev     Date        Author           Description
        -----   ----------  -------------    -----------------  
        1.0     29-JUL-22   norton.fan       Create the script 
*/

SET markup html ON spool ON entmap OFF


SET echo OFF
SET verify OFF
SET feedback OFF
SET termout OFF
SET pagesize 25
SET appinfo 'check_asm_usage.sql' 

COLUMN name             format a20    heading "NAME"
COLUMN type             format a8    heading "TYPE"
COLUMN free_mb          format 99,999,999    heading "FREE_MB"
COLUMN usage                     format 99,999,999 heading  "USAGE"
COLUMN total_mb                 format 99,999,999    heading "TOTAL_MB"

spool /tmp/check_ASM_usage.html


ttitle center "List the ASM diskgroup that fall into low water mark"  skip 2
 

select NAME,TYPE,FREE_MB,round((1 - free_mb / total_mb) * 100) || '%' as USAGE ,TOTAL_MB from v$asm_diskgroup where  round((1 - free_mb / total_mb) * 100) >85 and free_mb<300000;




SET markup html OFF
spool OFF
SET pagesize 14
ttitle OFF
SET feedback ON
SET termout ON
SET appinfo OFF
SET echo ON

EXIT