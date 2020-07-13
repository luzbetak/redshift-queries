SELECT 'grant '||privilege_type||' on '||table_schema||'.'||TABLE_NAME||' to '||grantee||CASE is_grantable
    WHEN 'YES' THEN ' with grant option;'
    ELSE ';'
    END
FROM information_schema.table_privileges
WHERE grantee='username';
