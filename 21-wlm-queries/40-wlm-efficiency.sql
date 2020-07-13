 WITH generate_dt_series AS
(
       SELECT sysdate - (n * interval '5 second') AS dt
       FROM   (
                     SELECT row_number() OVER () AS n
                     FROM   stl_scan limit 7*24*3600/5)), apex AS
(
         SELECT   iq.dt,
                  iq.service_class,
                  iq.num_query_tasks,
                  count(iq.slot_count) AS service_class_queries,
                  sum(iq.slot_count)   AS service_class_slots
         FROM     (
                            SELECT    gds.dt,
                                      wq.service_class,
                                      wscc.num_query_tasks,
                                      wq.slot_count
                            FROM      stl_wlm_query wq
                            LEFT JOIN stv_wlm_service_class_config wscc
                            ON        (
                                                wscc.service_class = wq.service_class
                                      AND       wscc.service_class > 4)
                            JOIN      generate_dt_series gds
                            ON        (
                                                wq.service_class_start_time <= gds.dt
                                      AND       wq.service_class_end_time > gds.dt)
                            WHERE     wq.userid > 1
                            AND       wq.service_class > 4) iq
         GROUP BY iq.dt,
                  iq.service_class,
                  iq.num_query_tasks), maxes AS
(
         SELECT   apex.service_class,
                  trunc(apex.dt)                   AS d,
                  lpad(date_part(h,apex.dt),2,'0') AS dt_h,
                  max(service_class_slots)            max_service_class_slots
         FROM     apex
         GROUP BY apex.service_class,
                  apex.dt,
                  date_part(h,apex.dt))
SELECT    *
FROM      (
                    SELECT    apex.service_class,
                              apex.num_query_tasks AS max_wlm_concurrency,
                              maxes.d              AS day,
                              maxes.dt_h
                                        || ':00 - '
                                        || maxes.dt_h
                                        || ':59'            AS hour,
                              max(apex.service_class_slots) AS max_service_class_slots
                    FROM      apex
                    LEFT JOIN maxes
                    ON        (
                                        apex.service_class = maxes.service_class
                              AND       apex.service_class_slots = maxes.max_service_class_slots)
                    GROUP BY  apex.service_class,
                              apex.num_query_tasks,
                              maxes.d,
                              maxes.dt_h) a
LEFT JOIN
          (
                   SELECT   trunc(service_class_start_time) AS day,
                            lpad(date_part(h,service_class_start_time),2,'0')
                                     ||':00 - '
                                     ||lpad(date_part(h,service_class_start_time),2,'0')
                                     ||':59' AS hour,
                            service_class,
                            avg(total_queue_time                                        /1000000) avg_wlm_queue_s,
                            max(total_queue_time                                        /1000000) max_wlm_queue_s,
                            avg(total_exec_time                                         /1000000) avg_run_s,
                            min(total_exec_time                                         /1000000) min_run_s,
                            max(total_exec_time                                         /1000000) max_run_s,
                            median(total_exec_time                                      /1000000) median_exec_time_s,
                            percentile_cont(0.85) within GROUP (ORDER BY total_exec_time/1000000) p85_exec_time_s,
                            percentile_cont(0.9) within GROUP (ORDER BY total_exec_time /1000000) p90_exec_time_s,
                            percentile_cont(0.95) within GROUP (ORDER BY total_exec_time/1000000) p95_exec_time_s,
                            count(query)                                                          total_queries
                   FROM     stl_wlm_query
                   WHERE    service_class > 4
                   GROUP BY 1,
                            2,
                            3) b
using     (day,hour,service_class)
ORDER BY  1,
          2,
          3; 
