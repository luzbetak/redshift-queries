 SELECT IQ.*,
       ( ( IQ.wlm_queue_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) ::
       Decimal(5, 2)
       AS pct_wlm_queue_time,
       ( ( IQ.exec_only_time * 1.0 / IQ.wlm_start_commit_time ) * 100 ) ::
       Decimal(5, 2)
       AS pct_exec_only_time_us,
( ( IQ.commit_queue_time :: FLOAT / IQ.wlm_start_commit_time ) * 100 ) :: Decimal(5, 2) pct_commit_queue_time,
( ( IQ.commit_time :: FLOAT / IQ.wlm_start_commit_time ) * 100 ) ::
Decimal(5, 2)
       pct_commit_time
FROM   (SELECT Trunc(b.starttime)                                       AS day,
               d.service_class,
               c.node,
               Count(DISTINCT c.xid)                                    AS
                      count_commit_xid,
               SUM(Datediff(us, d.service_class_start_time, c.endtime)) AS
               wlm_start_commit_time,
               SUM(Datediff(us, d.queue_start_time, d.queue_end_time))  AS
                      wlm_queue_time,
               SUM(Datediff(us, b.starttime, b.endtime))                AS
                      exec_only_time,
               SUM(Datediff(us, c.startwork, c.endtime))
               commit_time,
               SUM(Datediff(us,
                   Decode(c.startqueue, '2000-01-01 00:00:00', c.startwork,
                                        c.startqueue), c.startwork))
                                                           commit_queue_time
        FROM   stl_query b,
               stl_commit_stats c,
               stl_wlm_query d
        WHERE  b.xid = c.xid
               AND b.query = d.query
               AND d.service_class > 4
               AND c.node =- 1
               AND c.xid > 0
        GROUP  BY Trunc(b.starttime),
                  d.service_class,
                  c.node) IQ
ORDER  BY 1,
          3,
          2;  
