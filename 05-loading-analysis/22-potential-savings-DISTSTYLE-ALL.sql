SELECT DATABASE,
       SCHEMA,
       COUNT(*) table_count,
       SUM(tbl_rows) total_rows,
       SUM(SIZE) current_size,
       SUM(SIZE) / 32 new_size,
       SUM(SIZE) - (SUM(SIZE) / 32) potential_savings
FROM svv_table_info
WHERE (tbl_rows :: NUMERIC / SIZE :: NUMERIC) < 100
  AND tbl_rows < 1000000
GROUP BY DATABASE,
         SCHEMA
ORDER BY potential_savings DESC ;
