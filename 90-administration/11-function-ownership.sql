create or replace view v_func_owner as 
select pgu.usename as owner,nc.nspname as schemaname,pproc.proname proc_name,pg_catalog.oidvectortypes(pproc.proargtypes) as arguments
from 
pg_proc pproc,pg_namespace nc, pg_user pgu 
where pproc.pronamespace=nc.oid and pproc.proowner=pgu.usesysid and pproc.proowner>1;

