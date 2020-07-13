SELECT   iq.*,
         ((iq.total_compile_time::float/iq.wlm_start_commit_time)*100)::decimal(5,2) AS pct_compile_time,
         ((iq.wlm_queue_time::float    /iq.wlm_start_commit_time)*100)::decimal(5,2) AS pct_wlm_queue_time,
         ((iq.exec_only_time::float    /iq.wlm_start_commit_time)*100)::decimal(5,2) AS pct_exec_only_time,
         ((iq.commit_queue_time::float /iq.wlm_start_commit_time)*100)::decimal(5,2)    pct_commit_queue_time,
         ((iq.commit_time::float       /iq.wlm_start_commit_time)*100)::decimal(5,2)    pct_commit_time
FROM     (
                  SELECT   trunc(d.service_class_start_time) AS day,
                           d.service_class,
                           c.node,
                           count(DISTINCT c.xid) AS count_commit_xid,
                           sum(compile_us)       AS total_compile_time,
                           sum(datediff(us,
                           CASE
                                    WHEN d.service_class_start_time > compile_start THEN compile_start
                                    ELSE d.service_class_start_time
                           END, d.queue_end_time))                                                    AS wlm_queue_time,
                           sum(datediff(us, d.queue_end_time, d.service_class_end_time) - compile_us) AS exec_only_time,
                           sum(datediff(us,
                           CASE
                                    WHEN node > -1 THEN c.startwork
                                    ELSE c.startqueue
                           END, c.startwork))                        commit_queue_time,
                           sum(datediff(us, c.startwork, c.endtime)) commit_time,
                           sum(datediff(us,
                           CASE
                                    WHEN d.service_class_start_time > compile_start THEN compile_start
                                    ELSE d.service_class_start_time
                           END, d.service_class_end_time) -
                           CASE
                                    WHEN node > -1 THEN datediff(us,
                                             CASE
                                                      WHEN d.service_class_start_time > compile_start THEN compile_start
                                                      ELSE d.service_class_start_time
                                             END, d.queue_end_time)
                                    ELSE 0
                           END + datediff(us,
                           CASE
                                    WHEN node > -1 THEN c.startwork
                                    ELSE c.startqueue
                           END, c.endtime)) AS wlm_start_commit_time
                  FROM     stl_commit_stats c
                  JOIN     stl_wlm_query d
                  using    (xid)
                  JOIN
                           (
                                    SELECT   query,
                                             min(starttime)                      AS compile_start,
                                             sum(datediff(us,starttime,endtime)) AS compile_us
                                    FROM     svl_compile
                                    GROUP BY 1) e
                  using    (query)
                  WHERE    c.xid > 0
                  AND      d.service_class > 4
                  GROUP BY trunc(d.service_class_start_time),
                           d.service_class,
                           c.node
                  ORDER BY trunc(d.service_class_start_time),
                           d.service_class,
                           c.node ) iq
ORDER BY 1,
         2,
         3; 
