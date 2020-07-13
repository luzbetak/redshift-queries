CREATE OR REPLACE VIEW v_database_privs AS
SELECT u_grantor.usename::information_schema.sql_identifier AS grantor,
       grantee.name::information_schema.sql_identifier AS grantee,
       CASE grantee.grosysid
           WHEN TRUE THEN 'GROUP'
           ELSE 'USER'
       END AS user_type,
       nc.datname::CHARACTER varying AS DATABASE,
       (pr."type") AS privilege_type,
       CASE
           WHEN aclcontains(nc.datacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type", TRUE)) THEN 'YES'::text
           ELSE 'NO'::text
       END AS is_grantable,
       'NO' AS with_hierarchy
FROM pg_database nc,
     pg_user u_grantor, ((((
                              (SELECT pg_user.usesysid,
                                      0,
                                      pg_user.usename
                               FROM pg_user)
                            UNION ALL
                              (SELECT 0,
                                      pg_group.grosysid,
                                      pg_group.groname
                               FROM pg_group)))
                          UNION ALL
                            (SELECT 0,
                                    0,
                                    'PUBLIC'))) grantee(usesysid, grosysid, name), (
                                                                                      (SELECT 'CREATE')
                                                                                    UNION ALL
                                                                                      (SELECT 'TEMP')) pr("type")
WHERE aclcontains(nc.datacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type", FALSE))
  AND nc.datname::CHARACTER varying NOT LIKE 'template%';

