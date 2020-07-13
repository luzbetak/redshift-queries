WITH acq_rel AS
  (SELECT DATE_TRUNC('hour', eventtime) AS data_period,
          action,
          eventtime event_start,
          NULL::TIMESTAMP event_end,
          NULL AS cnt,
          num_nodes,
          BTRIM(cluster_arn) AS cluster_arn
   FROM stl_burst_service_client
   WHERE error = ''
     AND eventtime BETWEEN DATE_TRUNC('day', GETDATE()-1) AND DATE_TRUNC('day', GETDATE()) ) SELEC T acq.data_period,
                                                                                                   acq.action,
                                                                                                   DATE_TRUNC('sec', acq.event_start) event_start,
                                                                                                   DATE_TRUNC('sec', rel.event_start) event_end,
                                                                                                   DATEDIFF('sec', acq.event_start, NVL(rel.event_start, acq.event_start)) secs,
                                                                                                   acq.num_nodes,
                                                                                                   acq.cnt err_cnt,
                                                                                                   NULL AS error
FROM acq_rel acq
LEFT JOIN acq_rel rel ON acq.cluster_arn = rel.cluster_arn
WHERE acq.action = 'ACQUIRE'
  AND rel.action = '    RELEASE'
UNION ALL
SELECT data_period,
       action,
       DATE_TRUNC('sec', MIN(eventtime)) event_start,
       DATE_TRUNC('sec', MAX(eventtime)) event_end,
       DATEDIFF('sec', event_start, event_end) secs,
       num_nodes,
       COUNT(xid) err_cnt,
       error
FROM
  (SELECT DATE_TRUNC('hour', eventtime) AS data_period,
          'ERROR' AS action,
          eventtime,
          xid,
          num_nodes,
          LEFT(BTRIM(error), 80) AS error FRO M stl_burst_service_client
   WHERE error <> ''
     AND eventtime > CURRENT_DATE - 7 )
GROUP BY data_period,
         action,
         error,
         num_nodes
ORDER BY data_period,
         event_start
