set line 200
col name for a30
col value for a20
col isses_modifiable for a9
col ispdb_modifiable for a9
col isinstance_modifiable for a9
select name,value,isses_modifiable,issys_modifiable,ispdb_modifiable,isinstance_modifiable
from v$parameter
where name = 'db_files';


_allow_resetlogs_corruption为true（目的是跳过使用resetlogs open数据库的一致性检查）