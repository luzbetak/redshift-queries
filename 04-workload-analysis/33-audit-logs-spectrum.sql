drop table dory.redshiftuserlog;
CREATE EXTERNAL TABLE dory.redshiftuserlog (userid integer ,username varchar(50) ,oldusername varchar(50) ,action varchar(10) ,usecreatedb integer ,usesuper integer ,usecatupd integer ,valuntil bigint ,pid integer ,xid bigint ,recordtime varchar(50))
ROW FORMAT DELIMITED
fields terminated by '|'
LOCATION '';
select userid ,trim(username) as username,trim(oldusername) as oldusername,trim(action) as action,usecreatedb,usesuper,usecatupd,case when valuntil > 9223372036854775800 then null else TIMESTAMP  'epoch' + (((valuntil/1000000)+946684800) * INTERVAL '1 SECOND') end as valuntil,pid,xid,to_timestamp(recordtime,'xxx, dd Mon yyyy hh24:mi:ss:ms') from dory.redshiftuserlog where "$path" ilike '%userlog%' limit 10;

