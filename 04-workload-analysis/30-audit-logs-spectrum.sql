DROP TABLE dory.redshiftuseractivitylog;CREATE EXTERNAL TABLE dory.redshiftuseractivitylog (recordtime varchar(25) ,dbname varchar(150) ,username varchar(150) ,pid bigint ,userid bigint ,xid bigint ,log varchar(max) ) row format serde 'org.apache.hadoop.hive.serde2.RegexSerDe' WITH serdeproperties ( 'input.regex' = '^(?![0-9])''(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z UTC)\\s+\\[\\s+db=(.*?)\\s+user=(.*?)\\s+pid=(\\d+)\\s+userid=(\\d+)\\s+xid=(\\d+)\\s+\\]''\\s+LOG:(.*?)$' ) location '';CREATE OR replace VIEW v_redshiftuseractivitylog        ASSELECT To_timestamp(recordtime,'yyyy-mm-dd hh24:mi:ss') AS recordtime,
       dbname ,
       username ,
       pid ,
       userid ,
       xid ,
       log
FROM   dory.redshiftuseractivitylog
WHERE  "$path" ilike '%useractivity%' WITH no SCHEMA binding;SELECT To_timestamp(recordtime,'yyyy-mm-dd hh24:mi:ss') AS recordtime,
       dbname ,
       username ,
       pid ,
       userid ,
       xid ,
       log
FROM   dory.redshiftuseractivitylog
WHERE  "$path" ilike '%useractivity%' limit 5;

SELECT * FROM   v_redshiftuseractivitylog limit 10; 
