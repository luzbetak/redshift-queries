CREATE OR REPLACE VIEW v_user_privs AS
SELECT u_grantor.usename::information_schema.sql_identifier AS grantor,
       grantee.name::information_schema.sql_identifier AS grantee,
       CASE
           WHEN (grantee.name='PUBLIC'
                 OR grantee.grosysid) THEN 'GROUP'
           ELSE 'USER'
       END AS user_type,
       current_database()::information_sc hema.sql_identifier AS table_catalog,
       nc.nspname::information_schema.sql_identifier AS table_schema,
       c.relname::information_schema.sql_identifier AS TABLE_NAME,
       pr."type"::information_schema.character_data AS privilege_type,
       CASE
           WHEN aclcontains(c.relacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, TRUE)) THEN 'YES'::text
           ELSE 'NO'::text
       END::information_schema.character_data AS is_grantable,
       'NO'::information_schema.character_data::information_schema.character_data AS with_hierarchy
FROM pg_class c,
     pg_namespace nc,
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
     (
        (
           (
              (
                 (SELECT 'SELECT'::CHARACTER varying
                  UNION ALL SELECT 'DELETE'::CHARACTER varying)
               UNION ALL SELECT 'INSERT'::CHARACTER varying)
            UNION ALL SELECT 'UPDATE'::CHARACTER varying)
         UNION ALL SELECT 'REFERENCES'::CHARACTER varying)
      UNION ALL SELECT 'RULE'::CHARACTER varying)
   UNION ALL SELECT 'TRIGGER'::CHARACTER varying) pr("type")
WHERE c.relnamespace = nc.oid
  AND (c.relkind = 'r'::"char"
       OR c.relkind = 'v'::"char")
  AND aclcontains(c.relacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, FALSE))
  AND grantee.name <>'rdsdb';


SELECT *
FROM information_schema.table_privileges
WHERE grantee<>'admin'
  AND grantor<>'rdsdb';

