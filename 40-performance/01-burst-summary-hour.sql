SELECT DATE_TRUNC('hour', q.starttime) AS data_period,
       COUNT(*) AS qry_cnt,
       COUNT(DISTINCT q.xid) AS xid_cnt,
       SUM(CASE
               WHEN r.source_query IS NULL THEN 0
               ELSE 1
           END) AS cached_q,
       SUM(CASE
               WHEN w.service_class <> 14 THEN q.aborted
               ELSE 0
           END) AS abort_q,
       SUM(CASE
               WHEN w.service_class = 14
                    AND q.aborted = 0 THEN 1
               ELSE 0
           END) AS sqa_q,
       SUM(CASE
               WHEN w.service_class = 14
                    AND q.aborted = 1 THEN 1
               ELSE 0
           END) AS sqa_evict,
       SUM(CASE
               WHEN q.concurrency_scaling_status = 1 THEN 1
               ELSE 0
           END) AS burst_q,
       SUM(CASE
               WHEN q.concurrency_scaling_status = 1 THEN ROUND(w.total_queue_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS burst_queue_secs,
       SUM(CASE
               WHEN q.concurrency_scaling_status = 1 T HEN ROUND(w.total_exec_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS burst_exec_secs,
       SUM(CASE
               WHEN q.concurrency_scaling_status <> 1
                    AND w.service_class <> 14 THEN ROUND(w.total_queue_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS main_queue_secs,
       SUM(CASE
               WHEN q.concurrency_scaling_status <> 1
                    AND w.service_class <> 14 THEN ROUND(w.total_exec_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS main_exec_secs,
       SUM(CASE
               WHEN q.concurrency_scaling_status <> 1
                    AND w.service_class = 14 THEN ROUND(w.total_queue_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS sqa_queue_secs,
       SUM(CASE
               WHEN q.concurrency_scaling_status <> 1
                    AND w.service_class = 14 THEN ROUND(w.total_exec_time::NUMERIC / 1000000, 2)
               ELSE 0
           END) AS sqa_exec_secs,
       ROUND((SUM(w.total _exec_time)::NUMERIC + SUM(w.total_queue_time)::NUMERIC) / 1000000, 2) AS total_secs,
       ROUND((burst_q::NUMERIC / qry_cnt::NUMERIC) * 100, 2) AS burst_pct,
       ROUND((burst_exec_secs::NUMERIC / total_secs::NUMERIC) * 100, 2) AS burst_secs_pct
FROM stl_query AS q
LEFT JOIN svl_qlog AS r ON q.query = r.query
JOIN stl_wlm_query AS w ON q.userid = w.userid
AND q.query = w.qu ery
WHERE q.userid > 1
  AND q.starttime > DATE_TRUNC('day', GETDATE())
GROUP BY 1
ORDER BY 1;
