/*
    Program:  check_wait_event.sql
    Purpose:  notice no idle wait event
    History:
        Rev     Date        Author           Description
        -----   ----------  -------------    -----------------  
        1.0     1-aug-2023   norton.fan        Create the script 
*/

SET markup html ON spool ON entmap OFF


SET echo OFF
SET verify OFF
SET feedback OFF
SET termout OFF
SET pagesize 25
SET appinfo 'check_wait_event.sql' 


COLUMN event  format a35   heading "EVENT"
COLUMN wait_num        format 99,999 heading  "WAIT_NUM"

spool /tmp/check_wait_event.html


ttitle center "List NO IDLE wait time"  skip 2
 

select event,count(1) as wait_num  from gv$session_wait
where event in ('enq: TX - row lock contention',
'library cache lock','library cache pin','cursor: pin S wait on X','latch free','enqueue')  
group by event
having count(1)>10;

##根据自己需要添加等待事件
SET markup html OFF
spool OFF
SET pagesize 14
ttitle OFF
SET feedback ON
SET termout ON
SET appinfo OFF
SET echo ON

EXIT