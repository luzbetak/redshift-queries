SELECT DATE_TRUNC('day', start_time) AS test_name,
       SUM(queries) AS queries,
       SUM(usage_in_seconds) AS usage_secs
FROM svcs_concurrency_scaling_usage q
WHERE (q.start_time BETWEEN DATE_TRUNC('day', GETDATE()) AND GETDATE())
GROUP BY 1
ORDER BY 1;

