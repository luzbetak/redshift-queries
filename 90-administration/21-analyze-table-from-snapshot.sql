/*
If the customer runs analyze, it will use a histogram of the most frequent values and 
the number of total distinct values to calculate the selectivity for each predicate and 
order them in a way to move the one with the highest selectivity first
*/

SELECT CASE
           WHEN tbl > 0 THEN 'User_Table'
           WHEN tbl = 0 THEN 'Freed_Blocks'
           WHEN tbl = -2 THEN 'Catalog_File_Store'
           WHEN tbl = -3 THEN 'Metadata'
           WHEN tbl = -4 THEN 'Temp_Delete_Blocks'
           WHEN tbl = -6 THEN 'Query_Spill_To_Disk'
           WHEN tbl < -2000000 THEN 'Vacuum_Stage_Blocks'
           ELSE 'Stage_blocks_For_Real_Table_DML'
       END AS Block_type,
       CASE
           WHEN tombstone > 0 THEN 1
           ELSE 0
       END AS tombstone,
       count(1)
FROM stv_blocklist
GROUP BY 1,
         2
ORDER BY 1,
         2;
