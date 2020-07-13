SELECT 'grant '||privilege_type||' on schema '||schemaname||' to '||grantee||';'
FROM v_schema_privs
WHERE grantor='username';

