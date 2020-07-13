SELECT DISTINCT 'revoke all on schema '||schemaname||' from '||grantee||';'
FROM v_schema_privs
WHERE grantee='username';

