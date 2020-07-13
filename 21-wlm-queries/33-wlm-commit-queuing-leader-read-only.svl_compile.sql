SELECT *,
       pct_compile_time + pct_wlm_queue_time
       + pct_exec_only_time + pct_commit_queue_time
       + pct_commit_time AS total_pcnt
FROM   (

    SELECT IQ.*,
    ( ( IQ.total_compile_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) :: DECIMAL(5, 2) AS pct_compile_time,
    ( ( IQ.wlm_queue_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) ::
    DECIMAL(5, 2)
                   AS pct_wlm_queue_time,
    ( ( IQ.exec_only_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) ::
    DECIMAL(5, 2)
                   AS pct_exec_only_time,
    ( ( IQ.commit_queue_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) :: DECIMAL(5, 2)  pct_commit_queue_time,
    ( ( IQ.commit_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) :: DECIMAL(5, 2)
                   pct_commit_time
     FROM   (SELECT Trunc(d.service_class_start_time)
                            AS
                            day,
                    d.service_class,
                    d.node,
                    Count(DISTINCT d.xid)
                            AS count_all_xid,
                    Count(DISTINCT d.xid) - Count(DISTINCT c.xid)
                            AS count_readonly_xid,
                    Count(DISTINCT c.xid)
                            AS count_commit_xid,
                    Sum(compile_us)
                            AS total_compile_time,
                    Sum(Datediff(us, CASE
                                       WHEN d.service_class_start_time >
                                            compile_start THEN
                                       compile_start
                                       ELSE d.service_class_start_time
                                     end, d.queue_end_time))
                            AS wlm_queue_time,
                    Sum(Datediff(us, d.queue_end_time, d.service_class_end_time)
                        - compile_us) AS
                    exec_only_time,
                    Nvl(Sum(Datediff(us, CASE
                                           WHEN node > -1 THEN c.startwork
                                           ELSE c.startqueue
                                         end, c.startwork)), 0)
                            commit_queue_time,
                    Nvl(Sum(Datediff(us, c.startwork, c.endtime)), 0)
                            commit_time,
                    Sum(Datediff(us, CASE WHEN d.service_class_start_time >
                        compile_start
                        THEN
                        compile_start ELSE d.service_class_start_time end,
                        d.service_class_end_time)
                        + CASE WHEN c.endtime IS NULL THEN 0 ELSE (Datediff(us, CASE
                        WHEN
                        node > -1
                        THEN c.startwork ELSE c.startqueue end, c.endtime)) end)
                            AS
                    wlm_start_commit_time
             FROM   (SELECT node,
                            b.*
                     FROM   (SELECT -1 AS node
                             UNION
                             SELECT node
                             FROM   stv_slices) a,
                            stl_wlm_query b
                     WHERE  queue_end_time > '2005-01-01'
                            AND exec_start_time > '2005-01-01') d
                    LEFT JOIN stl_commit_stats c USING (xid, node)
                    JOIN (SELECT query,
                                 Min(starttime)                        AS
                                 compile_start,
                                 Sum(Datediff(us, starttime, endtime)) AS compile_us
                          FROM   svl_compile
                          GROUP  BY 1) e USING (query)
             WHERE  d.xid > 0
                    AND d.service_class > 4
                    AND d.final_state <> 'Evicted'
             GROUP  BY Trunc(d.service_class_start_time),
                       d.service_class,
                       d.node
             ORDER  BY Trunc(d.service_class_start_time),
                       d.service_class,
                       d.node) IQ
)
ORDER  BY 1,
          2,
          3;  
