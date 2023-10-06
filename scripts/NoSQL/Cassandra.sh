#连接数据库
cqlsh 192.168.1.61 -u cassandra -p cassandra
#查看集群信息
desc cluster;

nodetool status
#集群描述信息
nodetool describecluster
#查看当前所有的数据库
desc keyspaces
#切换数据库
use dbname;
#查看所有用户
LIST USERS;

#创建一个 keyspace：
CREATE KEYSPACE fgdatabase
WITH REPLICATION = {'class':'SimpleStrategy','replication_factor':3};


CREATE KEYSPACE "fgdcdatabase"
WITH REPLICATION = {'class':'NetworkTopologyStrategy', 'fgdc1' : 3, 'fgdc2' : 3};
#使用某个 keyspace：
use fgdcdatabase;


#创建一张表：
create table fgedu02 (id int, user_name varchar, primary key (id) );
insert into fgedu02 (id,user_name) VALUES (1,'fgedu01');
insert into fgedu02 (id,user_name) VALUES (2,'fgedu02');
INSERT INTO fgedu02 (id, user_name) VALUES (3, 'itpux03');
INSERT INTO fgedu02 (id, user_name) VALUES (4, 'itpux04');
INSERT INTO fgedu02 (id, user_name) VALUES (5, 'itpux05');