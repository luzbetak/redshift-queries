SELECT DATABASE,
       SCHEMA,
       "table",
       SIZE,
       sortkey1,
       NVL(s.num_qs, 0) num_queries
FROM svv_table_info t
LEFT JOIN
  (SELECT tbl,
          perm_table_name,
          COUNT(DISTINCT query) num_qs
   FROM stl_scan s
   WHERE s.userid > 1
     AND s.perm_table_name NOT IN ('Internal Worktable',
                                   'S3')
   GROUP BY 1,
            2) s ON s.tbl = t.table_id
WHERE NVL(s.num_qs, 0) = 0
ORDER BY SIZE DESC
LIMIT 25;
