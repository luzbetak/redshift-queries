SELECT column_name,
       ordinal_position
FROM   information_schema.columns
WHERE  table_name = 'listing'
       AND table_schema = 'public'
ORDER  BY ordinal_position;  
