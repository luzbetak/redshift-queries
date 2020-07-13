SELECT a.endtime::date,
       a.tbl,
       trim(c.nspname) AS "schema",
       trim(b.relname) AS "tablename",
       sum(a.rows_inserted) AS "rows_inserted",
       sum(d.distinct_files) AS files_scanned,
       sum(d.MB_scanned) AS MB_scanned,
       (sum(d.distinct_files)::numeric(19, 3)/count(DISTINCT a.query)::numeric(19, 3))::numeric(19, 3) AS avg_files_per_copy,
       (sum(d.MB_scanned)/sum(d.distinct_files)::numeric(19, 3))::numeric(19, 3) AS avg_file_size_mb,
       count(DISTINCT a.query) no_of_copy,
       max(a.query) AS sample_query,
       (sum(d.MB_scanned)*1024*1000000/SUM(d.load_micro)) AS scan_rate_kbps,
       (sum(a.rows_inserted)*1000000/SUM(a.insert_micro)) AS insert_rate_rows_ps
FROM
  (SELECT query,
          tbl,
          sum(ROWS) AS rows_inserted,
          max(endtime) AS endtime,
          datediff('microsecond', min(starttime), max(endtime)) AS insert_micro
   FROM stl_insert
   GROUP BY query,
            tbl) a,
     pg_class b,
     pg_namespace c,

  (SELECT b.query,
          count(DISTINCT b.bucket||b.key) AS distinct_files,
          sum(b.transfer_size)/1024/1024 AS MB_scanned,
          sum(b.transfer_time) AS load_micro
   FROM stl_s3client b
   WHERE b.http_method = 'GET'
   GROUP BY b.query) d
WHERE a.tbl = b.oid
  AND b.relnamespace = c.oid
  AND d.query = a.query
GROUP BY 1,
         2,
         3,
         4
ORDER BY 1 DESC,
         5 DESC,
         3,
         4
LIMIT 50;
