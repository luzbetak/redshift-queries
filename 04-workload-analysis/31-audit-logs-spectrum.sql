DROP table dory.redshiftuseractivitylog;
CREATE EXTERNAL TABLE dory.redshiftuseractivitylog (recordtime varchar(25) ,dbname varchar(150) ,username varchar(150) ,pid bigint ,userid bigint ,xid bigint ,log varchar(max)
) partitioned by (
account bigint,
region varchar(15),
clusterid varchar,
year bigint,
month smallint,
day smallint)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
 WITH SERDEPROPERTIES (
 'input.regex' = '^(?![0-9])''(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z UTC)\\s+\\[\\s+db=(.*?)\\s+user=(.*?)\\s+pid=(\\d+)\\s+userid=(\\d+)\\s+xid=(\\d+)\\s+\\]''\\s+LOG:(.*?)$'
 ) LOCATION 's3://krshift-audit-logs/auditlogs/AWS/redshift/newpath/useractivitylog/';
select * from dory.redshiftuseractivitylog;

