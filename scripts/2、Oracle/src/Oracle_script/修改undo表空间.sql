--�ؽ�Oracle undo��ռ��ļ������ݿ�״̬��ֹʱ����DML�����ڼ䣩ִ��UNDO��ռ��л���
--��UNDOTBS2��ռ������ʹ��sqlplus��¼�����ڵ�ִ�С�
--1����ѯundo��ռ���Ϣ��
select * from dba_tablespaces where contents = 'UNDO';
show parameter undo_;
--2����ѯundo��ռ������ļ����ļ���С
select file_id, file_name, sum(bytes) / 1024 / 1024 "�ļ���С(MB)"
  from dba_data_files
 where tablespace_name in
       (select tablespace_name from dba_tablespaces where contents = 'UNDO')
 group by file_id, file_name;
--3��������undo��ռ�
create undo tablespace UNDOTBS2 datafile '+DATA/racdb/datafile/undotbs02.dbf' size 210M;
--4��������undo��ռ�ΪĬ�ϱ�ռ�
alter system set undo_tablespace = UNDOTBS2 scope=both;
--5����ѯ���Ľ��
select * from dba_tablespaces where contents = 'UNDO';
show parameter undo_;
--6�����ȷ���������undo��ռ����Ƿ����ONLINE��segment
select status,segment_name from dba_rollback_segs where status not in ('OFFLINE') and tablespace_name='UNDOTBS2';
--7��ɾ��ԭ�ȵ�undo��ռ估�ļ�
Drop tablespace UNDO_002 including contents and datafiles;
--8���ر����ݿ�
shutdown immediate
--9���������ݿ�
startup
--10��Ϊ�˱�֤������һ�£���������pfile�ļ����ڸ����ڵ���ִ��
create pfile from spfile;
