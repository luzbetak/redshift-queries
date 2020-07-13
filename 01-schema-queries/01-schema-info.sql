/*TRIM queries */
SELECT TRIM(db_name) AS db_name,
       TRIM(SCHEMA_NAME) AS SCHEMA_NAME,
       TO_CHAR(SUM(rows_total), '999,999,999,999') rows_total,
       TO_CHAR(SUM(COALESCE(size_in_gb, 0)), '999,999,999,999') size_in_gb
FROM
  (SELECT id table_id,
          datname db_name,
          nspname SCHEMA_NAME,
                  relname TABLE_NAME,
                          SUM(ROWS) rows_total,
                          SUM(sorted_rows) rows_sorted
   FROM stv_tbl_perm
   JOIN pg_class ON pg_class.oid = stv_tbl_perm.id
   JOIN pg_namespace ON pg_namespace.oid = relnamespace
   JOIN pg_database ON pg_database.oid = stv_tbl_perm.db_id
   WHERE name NOT LIKE 'pg_%'
     AND name NOT LIKE 'stl_%'
     AND name NOT LIKE 'stp_%'
     AND name NOT LIKE 'padb_%'
     AND nspname <> 'pg_catalog'
   GROUP BY id,
            datname,
            nspname,
            relname
   ORDER BY id,
            datname,
            nspname,
            relname) tbl_det
LEFT JOIN
  (SELECT tbl table_id,
          ROUND(CONVERT(REAL,COUNT(*))/1024, 2) size_in_gb
   FROM stv_blocklist bloc
   GROUP BY tbl) tbl_size ON tbl_size.table_id = tbl_det.table_id
GROUP BY 1,
         2
ORDER BY size_in_gb DESC;
