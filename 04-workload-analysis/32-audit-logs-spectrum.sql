drop table dory.redshiftuserconnectionlog;
CREATE EXTERNAL TABLE dory.redshiftuserconnectionlog (event varchar(50) ,recordtime varchar(50) ,remotehost varchar(32) ,remoteport integer ,pid integer ,dbname varchar(50) ,username varchar(50) ,authmethod varchar(32) ,duration bigint ,sslversion varchar(50) ,sslcipher  varchar(128) ,mtu integer ,sslcompression varchar(64) ,sslexpansion varchar(64) ,iamauthguid varchar(36) ,application_name varchar(250))
ROW FORMAT DELIMITED
fields terminated by '|'
LOCATION '';
select trim(event) as event ,to_timestamp(recordtime,'xxx, dd Mon yyyy hh24:mi:ss:ms') ,trim(remotehost) as remotehost ,remoteport ,pid ,trim(dbname) as dbname ,trim(username) as username ,trim(authmethod) as authmethod ,duration ,trim(sslversion) as sslversion ,trim(sslcipher) as sslcipher ,mtu ,trim(sslcompression) as sslcompression ,trim(sslexpansion) as sslexpansion ,trim(iamauthguid) as iamauthguid ,trim(application_name) as application_name from dory.redshiftuserconnectionlog where "$path" ilike '%connectionlog%' limit 10;

