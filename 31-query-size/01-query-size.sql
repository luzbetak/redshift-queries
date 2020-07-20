SELECT pg_user.usename,
       stl_query_metrics.query,
       querytxt,
       query_execution_time,
       query_cpu_usage_percent,
       query_temp_blocks_to_disk,
       stl_query.starttime
FROM   stl_query_metrics
       JOIN svl_query_metrics_summary
         ON stl_query_metrics.query = svl_query_metrics_summary.query
       JOIN pg_user
         ON pg_user.usesysid = stl_query_metrics.userid
       JOIN stl_query
         ON stl_query.query = stl_query_metrics.query
WHERE  query_temp_blocks_to_disk > 100000
       AND stl_query_metrics.starttime > '2020-07-20 01:00:00'
ORDER  BY query_execution_time DESC
LIMIT  20;  

