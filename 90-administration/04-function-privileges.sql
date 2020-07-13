create or replace view v_func_privs as 
SELECT u_grantor.usename::information_schema.sql_identifier AS grantor, 
grantee.name::information_schema.sql_identifier AS grantee,
(select usename from pg_user where usesysid=pproc.proowner) as proc_owner,
case when (grantee.name='PUBLIC' or grantee.grosysid) then 'GROUP' else 'USER' end as user_type, 
nc.nspname as schemaname,
pproc.proname proc_name,
pg_catalog.oidvectortypes(pproc.proargtypes) as arguments, 
pr."type"::information_schema.character_data AS privilege_type, 
        CASE
            WHEN aclcontains(pproc.proacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, true)) THEN 'YES'::text when grantee.grosysid then 'NO' when u_grantor.usesysid=pproc.proowner then 'OWNER'
            ELSE 'NO'::text
        END::information_schema.character_data AS is_grantable
   FROM pg_proc pproc,pg_namespace nc, pg_user u_grantor, (( SELECT pg_user.usesysid, 0, pg_user.usename
           FROM pg_user
UNION ALL 
SELECT 0, pg_group.grosysid, pg_group.groname FROM pg_group)
UNION ALL 
         SELECT 0, 0, 'PUBLIC'::name) grantee(usesysid, grosysid, name), ((
 
         SELECT 'EXECUTE'::character varying)
) pr("type")
  WHERE aclcontains(pproc.proacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, false)) and pproc.proowner > 1 and pproc.pronamespace=nc.oid;

