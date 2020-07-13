CREATE OR REPLACE VIEW v_schema_privs AS
SELECT u_grantor.usename::information_schema.sql_identifier AS grantor,
       grantee.name::information_schema.sql_identifier AS grantee,
       CASE
           WHEN (grantee.name='PUBLIC'
                 OR grantee.grosysid) THEN 'GROUP'
           ELSE 'USER'
       END AS user_type,
       current_database()::information_sc hema.sql_identifier AS dbname,
       nc.nspname::information_schema.sql_identifier AS schemaname,
       pr."type"::information_schema.character_data AS privilege_type,
       CASE
           WHEN aclcontains(nc.nspacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, TRUE)) THEN 'YES'::text
           ELSE 'NO'::text
       END::information_schema.character_data AS is_grantable,
       'NO'::information_schema.character_data::information_schema.character_data AS with_hierarchy
FROM pg_namespace nc,
     pg_user u_grantor,
  (
     (SELECT pg_user.usesysid,
             0,
             pg_user.usename
      FROM pg_user
      UNION ALL SELECT 0,
                       pg_group.grosysid,
                       pg_group.groname
      FROM pg_group)
   UNION ALL SELECT 0,
                    0,
                    'PUBLIC'::name) grantee(usesysid, grosysid, name),
  (
     (SELECT 'USAGE'::CHARACTER varying)
   UNION ALL SELECT 'CREATE'::CHARACTER varying) pr("type")
WHERE aclcontains(nc.nspacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, FALSE))
  AND grantee.name <>'rdsdb';
