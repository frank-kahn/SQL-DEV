col comp_id for a10
col comp_name for a56
col version for a12
col status for a10
set pagesize 200
set lines 200
set long 999
select comp_id,comp_name,version,status from dba_registry;