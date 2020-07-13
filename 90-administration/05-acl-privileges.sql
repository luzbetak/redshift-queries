CREATE OR REPLACE VIEW V_DEFAULT_ACL_PRIVS AS
SELECT u_grantor.usename AS grantor, grantee.name AS grantee,case when (grantee.name='PUBLIC' or grantee.grosysid) then 'GROUP' else 'USER' end as grantee_type, current_database() AS databasename, pda.defaclnamespace AS schemaid,(select pgn.nspname from pg_namespace pgn where pgn.oid=pda.defaclnamespace) as schemaname, 
case pda.defaclobjtype when 'r' then 'TABLES' else 'FUNCTIONS' end AS acl_object_type, pr."type" AS privilege_type, 
        CASE
            WHEN aclcontains(pda.defaclacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, true)) THEN 'YES'::text
            ELSE 'NO'::text
        END::information_schema.character_data AS is_grantable, 'NO'::information_schema.character_data::information_schema.character_data AS with_hierarchy
   FROM pg_default_acl pda, pg_user u_grantor, (( SELECT pg_user.usesysid, 0, pg_user.usename
           FROM pg_user
UNION ALL 
         SELECT 0, pg_group.grosysid, pg_group.groname
           FROM pg_group)
UNION ALL 
         SELECT 0, 0, 'PUBLIC'::name) grantee(usesysid, grosysid, name), (((((( SELECT 'SELECT'::character varying
UNION ALL 
         SELECT 'DELETE'::character varying)
UNION ALL 
         SELECT 'INSERT'::character varying)
UNION ALL 
         SELECT 'UPDATE'::character varying)
UNION ALL 
         SELECT 'REFERENCES'::character varying)
UNION ALL 
         SELECT 'RULE'::character varying)
UNION ALL 
         SELECT 'TRIGGER'::character varying) pr("type")
  WHERE aclcontains(pda.defaclacl, makeaclitem(grantee.usesysid, grantee.grosysid, u_grantor.usesysid, pr."type"::text, false));

