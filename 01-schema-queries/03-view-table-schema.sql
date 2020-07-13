/*
	Display table schema for particular table name
*/
SELECT distinct(tablename) 
FROM pg_table_def
WHERE schemaname = 'pg_catalog';

