SELECT 'revoke '||privilege_type||' on '||table_schema||'.'||TABLE_NAME||' from '||grantee||';'
FROM information_schema.table_privileges
WHERE grantee='username';
