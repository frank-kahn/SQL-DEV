set linesize 260 pagesize 1000;
col h0 for 999
col h1 for 999; 
col h2 for 999; 
col h3 for 999; 
col h4 for 999; 
col h5 for 999; 
col h6 for 999; 
col h7 for 999; 
col h8 for 999; 
col h9 for 999; 
col h10 for 999; 
col h11 for 999; 
col h12 for 999; 
col h13 for 999; 
col h14 for 999; 
col h15 for 999; 
col h16 for 999; 
col h17 for 999; 
col h18 for 999; 
col h19 for 999; 
col h20 for 999
col h21 for 999; 
col h22 for 999; 
col h23 for 999;  
SELECT TRUNC(first_time) "Date",
       TO_CHAR(first_time, 'Dy') "Day",
       COUNT(1) "Total",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '00', 1, 0)) "h0",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '01', 1, 0)) "h1",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '02', 1, 0)) "h2",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '03', 1, 0)) "h3",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '04', 1, 0)) "h4",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '05', 1, 0)) "h5",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '06', 1, 0)) "h6",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '07', 1, 0)) "h7",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '08', 1, 0)) "h8",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '09', 1, 0)) "h9",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '10', 1, 0)) "h10",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '11', 1, 0)) "h11",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '12', 1, 0)) "h12",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '13', 1, 0)) "h13",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '14', 1, 0)) "h14",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '15', 1, 0)) "h15",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '16', 1, 0)) "h16",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '17', 1, 0)) "h17",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '18', 1, 0)) "h18",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '19', 1, 0)) "h19",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '20', 1, 0)) "h20",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '21', 1, 0)) "h21",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '22', 1, 0)) "h22",
       SUM(DECODE(TO_CHAR(first_time, 'hh24'), '23', 1, 0)) "h23",
       ROUND(COUNT(1) / 24, 2) "Avg"
  FROM v$log_history
 GROUP BY TRUNC(first_time), TO_CHAR(first_time, 'Dy')
 ORDER BY 1;