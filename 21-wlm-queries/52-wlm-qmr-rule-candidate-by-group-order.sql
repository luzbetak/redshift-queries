WITH usergrp AS
  (SELECT CASE
              WHEN pg_user.usesysid IN (102,
                                        104,
                                        105,
                                        107,
                                        108,
                                        109) THEN 'Group: bi_readonly'
              ELSE 'User: '||pg_user.usename
          END group_or_user,
          pg_user.usesysid userid
   FROM pg_user),
     qmr AS
  (SELECT group_or_user,
          'query_cpu_time' ::VARCHAR(30) qmr_metric,
          MEDIAN(query_cpu_time) p50,
          PERCENTILE_CONT(0.99) WITHIN GROUP (
                                              ORDER BY query_cpu_time) p99,
                                             MAX(query_cpu_time) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE query_cpu_time IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'query_blocks_read' ::VARCHAR(30) qmr_metric,
                    MEDIAN(query_blocks_read) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY query_blocks_read) p99,
                                                       MAX(query_blocks_read) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE query_blocks_read IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'query_execution_time' ::VARCHAR(30) qmr_metric,
                    MEDIAN(query_execution_time) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY query_execution_time) p99,
                                                       MAX(query_execution_time) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE query_execution_time IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'query_cpu_usage_percent' ::VARCHAR(30) qmr_metric,
                    MEDIAN(query_cpu_usage_percent) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY query_cpu_usage_percent) p99,
                                                       MAX(query_cpu_usage_percent) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE query_cpu_usage_percent IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'query_temp_blocks_to_disk' ::VARCHAR(30) qmr_metric,
                    MEDIAN(query_temp_blocks_to_disk) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY query_temp_blocks_to_disk) p99,
                                                       MAX(query_temp_blocks_to_disk) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE query_temp_blocks_to_disk IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'segment_execution_time' ::VARCHAR(30) qmr_metric,
                    MEDIAN(segment_execution_time) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY segment_execution_time) p99,
                                                       MAX(segment_execution_time) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE segment_execution_time IS NOT NULL
     AND userid > 1
     AND segment_execution_time >= 10
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'cpu_skew' ::VARCHAR(30) qmr_metric,
                    MEDIAN(cpu_skew) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY cpu_skew) p99,
                                                       MAX(cpu_skew) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE cpu_skew IS NOT NULL
     AND userid > 1
     AND segment_execution_time >= 10
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'io_skew' ::VARCHAR(30) qmr_metric,
                    MEDIAN(io_skew) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY io_skew) p99,
                                                       MAX(io_skew) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE io_skew IS NOT NULL
     AND userid > 1
     AND segment_execution_time >= 10
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'scan_row_count' ::VARCHAR(30) qmr_metric,
                    MEDIAN(scan_row_count) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY scan_row_count) p99,
                                                       MAX(scan_row_count) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE scan_row_count IS NOT NULL
     AND userid > 1
     AND segment_execution_time >= 10
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'join_row_count' ::VARCHAR(30) qmr_metric,
                    MEDIAN(join_row_count) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY join_row_count) p99,
                                                       MAX(join_row_count) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE join_row_count IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'nested_loop_join_row_count'::VARCHAR(30) qmr_metric,
                    MEDIAN(nested_loop_join_row_count) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY nested_loop_join_row_count) p99,
                                                       MAX(nested_loop_join_row_count) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE nested_loop_join_row_count IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'return_row_count' ::VARCHAR(30) qmr_metric,
                    MEDIAN(return_row_count) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY return_row_count) p99,
                                                       MAX(return_row_count) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE return_row_count IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'spectrum_scan_row_count' ::VARCHAR(30) qmr_metric,
                    MEDIAN(spectrum_scan_row_count) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY spectrum_scan_row_count) p99,
                                                       MAX(spectrum_scan_row_count) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE spectrum_scan_row_count IS NOT NULL
     AND userid > 1
   GROUP BY 1
   UNION ALL SELECT group_or_user,
                    'spectrum_scan_size_mb' ::VARCHAR(30) qmr_metric,
                    MEDIAN(spectrum_scan_size_mb) p50,
                    PERCENTILE_CONT(0.99) WITHIN GROUP (
                                                        ORDER BY spectrum_scan_size_mb) p99,
                                                       MAX(spectrum_scan_size_mb) pmax
   FROM svl_query_metrics
   JOIN usergrp USING(userid)
   WHERE spectrum_scan_size_mb IS NOT NULL
     AND userid > 1
   GROUP BY 1)
SELECT group_or_user,
       qmr_metric,
       p50,
       p99,
       pmax,
       (LEFT(p99, 1)::INT+1)*POWER(10, LENGTH((p99/10)::BIGINT)) qmr_rule,
       ROUND(pmax/((LEFT(p99, 1)::INT+1)*POWER(10, LENGTH((p99/10)::BIGINT))), 2) pmax_magnitude,
       ROW_NUMBER() OVER (PARTITION BY group_or_user
                          ORDER BY (NVL(pmax, 1)/((LEFT(p99, 1)::INT+1)*POWER(10, LENGTH((p99/10)::BIGINT)))) DESC) rule_order
FROM qmr
WHERE NVL(p99, 0) >= 10
  AND (NVL(p50, 0) + NVL(p99, 0)) < NVL(pmax, 0)
  AND ((LEFT(p99, 1)::INT+1)*POWER(10, LENGTH((p99/10)::BIGINT))) < NVL(pmax, 0)
ORDER BY 1,
         8 ;
