#echo "###异常对象####"
#su - oracle  -c"
sqlplus -S "/ as sysdba " << EOF
column OWNER format a10        heading 'OWNER' 
column OBJECT_NAME    format a80    heading 'OBJECT_NAME' 
column OBJECT_TYPE format a40        heading 'OBJECT_TYPE' 
set heading off
set feedback off
select OWNER,OBJECT_NAME, OBJECT_TYPE from dba_objects 
where object_name  in  
('DBMS_SUPPORT_INTERNAL','DBMS_SYSTEM_INTERNAL','DBMS_CORE_INTERNAL','DBMS_STANDARD_FUN9','DBMS_SUPPORT_INTERNAL','DBMS_SYSTEM_INTERNAL','DBMS_CORE_INTERNAL') or object_name like 'DBMS_SUPPORT_DBMONITOR%';
exit;
EOF
