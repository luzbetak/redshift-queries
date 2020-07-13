SELECT n.nspname::varchar(50) schemaname, c.relname::varchar(50) objname,
case c.relkind when 'r' then 'TABLE' when 'v' then 'VIEW' end as objtype, u.usename::varchar(50) objowner FROM ((pg_class c LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace))) left join (select usename,usesysid from pg_user) u on (c.relowner=u.usesysid)) WHERE (c.relkind in ('r','v')); 

SELECT n.nspname::varchar(50) schemaname, c.relname::varchar(50) objname, 
case c.relkind when 'r' then 'TABLE' when 'v' then 'VIEW' end as objtype, u.usename::varchar(50) objowner, c.relhasindex, c.relhasrules, (c.reltriggers > 0) AS hastriggers FROM ((pg_class c LEFT JOIN pg_namespace n ON ((n.oid = c.relnamespace))) left join (select usename,usesysid from pg_user) u on (c.relowner=u.usesysid)) WHERE (c.relkind in ('r','v')); 

select usename objowner,current_database() databasename,reltablespace,nspname schemaname,relname as objname,relkind from pg_class join pg_user on pg_class.relowner=pg_user.usesysid join pg_namespace on pg_class.relnamespace=pg_namespace.oid where pg_user.usename<>'rdsdb';

