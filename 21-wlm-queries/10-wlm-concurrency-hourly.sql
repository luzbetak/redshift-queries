SELECT date_trunc('h', starttime) AS day_hr,
       sum(CASE
               WHEN concurrency_scaling_status<>1 THEN 1
               ELSE 0
           END) main,
       sum(CASE
               WHEN concurrency_scaling_status=1 THEN 1
               ELSE 0
           END) bursted,
       sum(CASE
               WHEN concurrency_scaling_status<>1 THEN 1
               ELSE 0
           END),
       round(sum(CASE
                     WHEN concurrency_scaling_status<>1
                          AND NOT aborted THEN 1
                     ELSE 0
                 END)*100.0/count(query), 2) pcnt_main,
       round(sum(CASE
                     WHEN concurrency_scaling_status=1
                          AND NOT aborted THEN 1
                     ELSE 0
                 END)*100.0/count(query), 2) pcnt_bursted,
       sum(CASE
               WHEN aborted=0 THEN 1
               ELSE 0
           END) AS num_successful,
       sum(CASE
               WHEN aborted=1 THEN 1
               ELSE 0
           END) AS num_aborted,
       count(query)
FROM pg_catalog.stl_query
WHERE userid>1
GROUP BY 1
ORDER BY 1,
         2;

WITH qtime AS
  (SELECT service_class,
          date_trunc('h', service_class_start_time) schr,
          min(total_queue_time/1000000) min_total_queue_time_s,
          max(total_queue_time/1000000) max_total_queue_time_s,
          median(total_queue_time/1000000) p50_total_queue_time_s,
          percentile_cont(.85) WITHIN GROUP (
                                             ORDER BY total_queue_time/1000000) p85total_queue_time_s,
                                            percentile_cont(.9) WITHIN GROUP (
                                                                              ORDER BY total_queue_time/1000000) p90total_queue_time_s,
                                                                             percentile_cont(.95) WITHIN GROUP (
                                                                                                                ORDER BY total_queue_time/1000000) p95total_queue_time_s
   FROM stl_wlm_query
   GROUP BY 1,
            2),
     exectime AS
  (SELECT service_class,
          date_trunc('h', service_class_start_time) schr,
          min(total_exec_time/1000000) min_total_exec_time_s,
          max(total_exec_time/1000000) max_total_exec_time_s,
          median(total_exec_time/1000000) p50_total_exec_time_s,
          percentile_cont(.85) WITHIN GROUP (
                                             ORDER BY total_exec_time/1000000) p85_total_exec_time_s,
                                            percentile_cont(.9) WITHIN GROUP (
                                                                              ORDER BY total_exec_time/1000000) p90_total_exec_time_s,
                                                                             percentile_cont(.95) WITHIN GROUP (
                                                                                                                ORDER BY total_exec_time/1000000) p95_total_exec_time_s
   FROM stl_wlm_query
   GROUP BY 1,
            2),
     estpeakmem AS
  (SELECT service_class,
          date_trunc('h', service_class_start_time) schr,
          min(est_peak_mem/1024.0/1024)::decimal(7, 2) min_total_exec_time_s,
          max(est_peak_mem/1024.0/1024)::decimal(7, 2) max_total_exec_time_s,
          median(est_peak_mem/1024.0/1024)::decimal(7, 2) p50_est_peak_mem_mb,
          percentile_cont(.85) WITHIN GROUP (
                                             ORDER BY est_peak_mem/1024.0/1024)::decimal(7, 2) p85_est_peak_mem_mb,
                                            percentile_cont(.9) WITHIN GROUP (
                                                                              ORDER BY est_peak_mem/1024.0/1024)::decimal(7, 2) p90_est_peak_mem_mb,
                                                                             percentile_cont(.95) WITHIN GROUP (
                                                                                                                ORDER BY est_peak_mem/1024.0/1024)::decimal(7, 2) p95_est_peak_mem_mb
   FROM stl_wlm_query
   GROUP BY 1,
            2),
     wlmsummary AS (
SELECT service_class,
       date_trunc('h', service_class_start_time) schr,
       count(DISTINCT query) numqueries,
       min(slot_count) min_slot_count,
       max(slot_
SELECT *
FROM wlmsummary a
LEFT JOIN qtime b USING (service_class,
                         schr)
LEFT JOIN exectime c USING (service_class,
                            schr)
LEFT JOIN estpeakmem d USING (service_class,
                              schr)
ORDER BY 2,
         1;
