SELECT trim(s.perm_table_name) AS TABLE,
       (sum(abs(datediff(seconds, coalesce(b.starttime, d.starttime, s.starttime), 
                CASE
                  WHEN coalesce(b.endtime, d.endtime, s.endtime) > coalesce(b.starttime, d.starttime, s.starttime) THEN coalesce(b.endtime, d.endtime, s.endtime)
                  ELSE coalesce(b.starttime, d.starttime, s.starttime)
                END))) / 60)::NUMERIC(24, 0) AS minutes,
       sum(coalesce(b.rows, d.rows, s.rows)) AS ROWS,
       trim(split_part(l.event, ':', 1)) AS event,
       substring(trim(l.solution), 1, 60) AS solution,
       max(l.query) AS sample_query,
       count(DISTINCT l.query)
FROM stl_alert_event_log AS l
LEFT JOIN stl_scan AS s ON s.query = l.query
AND s.slice = l.slice
AND s.segment = l.segment
LEFT JOIN stl_dist AS d ON d.query = l.query
AND d.slice = l.slice
AND d.segment = l.segment
LEFT JOIN stl_bcast AS b ON b.query = l.query
AND b.slice = l.slice
AND b.segment = l.segment
WHERE l.userid > 1
  AND l.event_time >= dateadd(DAY, - 7, CURRENT_DATE)
GROUP BY 1,
         4,
         5
ORDER BY 2 DESC,
         6 DESC
LIMIT 15;
