SELECT MAX(a.query) last_query,
       MAX(a.xid) last_xid,
       COUNT(*) load_count,
       ROUND(SUM(COALESCE(b.comp_time, 0)) / 1000.00, 0) compression_secs,
       ROUND(SUM(COALESCE(a.copy_time, 0)) / 1000.00, 0) copy_load_secs,
       ROUND(SUM(COALESCE(c.analyze_time, 0)) / 1000.00, 0) analyse_secs,
       SUBSTRING(q.querytxt, 1, 150)
FROM
  (SELECT query,
          xid,
          datediff(ms, starttime, endtime) copy_time
   FROM stl_query q
   WHERE (querytxt ILIKE 'copy %from%')
     AND EXISTS
       (SELECT 1
        FROM stl_commit_stats cs
        WHERE cs.xid = q.xid )
     AND EXISTS
       (SELECT xid
        FROM stl_query
        WHERE query IN
            (SELECT DISTINCT query
             FROM stl_load_commits) ) ) a
LEFT JOIN
  (SELECT xid,
          SUM(datediff(ms, starttime, endtime)) comp_time
   FROM stl_query q
   WHERE (querytxt LIKE 'COPY ANALYZE %'
          OR querytxt LIKE 'analyze compression phase %')
     AND EXISTS
       (SELECT 1
        FROM stl_commit_stats cs
        WHERE cs.xid = q.xid )
     AND EXISTS
       (SELECT xid
        FROM stl_query
        WHERE query IN
            (SELECT DISTINCT query
             FROM stl_load_commits) )
   GROUP BY 1) b ON b.xid = a.xid
LEFT JOIN
  (SELECT xid,
          SUM(datediff(ms, starttime, endtime)) analyze_time
   FROM stl_query q
   WHERE (querytxt LIKE 'padb_fetch_sample%')
     AND EXISTS
       (SELECT 1
        FROM stl_commit_stats cs
        WHERE cs.xid = q.xid )
     AND EXISTS
       (SELECT xid
        FROM stl_query
        WHERE query IN
            (SELECT DISTINCT query
             FROM stl_load_commits) )
   GROUP BY 1) c ON c.xid = a.xid
INNER JOIN stl_query q ON q.query = a.query
WHERE (b.comp_time IS NOT NULL)
  OR (c.analyze_time > a.copy_time)
GROUP BY SUBSTRING(q.querytxt, 1, 150)
ORDER BY (ROUND(SUM(COALESCE(b.comp_time, 0)) / 1000.00, 0) + ROUND(SUM(COALESCE(a.copy_time, 0)) / 1000.00, 0) + ROUND(SUM(COALESCE(c.analyze_time, 0)) / 1000.00, 0)) DESC
LIMIT 50;
