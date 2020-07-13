WITH generate_dt_series AS
  (SELECT SYSDATE-(n*INTERVAL '5 second') AS dt
   FROM
     (SELECT ROW_NUMBER() OVER () AS n
      FROM stl_scan
      LIMIT 120960)),
     apex AS
  (SELECT iq.dt,
          iq.service_class,
          iq.num_query_tasks,
          COUNT(iq.slot_count) AS service_class_queries,
          SUM(iq.slot_count) AS service_class_slots
   FROM
     (SELECT gds.dt,
             wq.service_class,
             wscc.num_query_tasks,
             wq.slot_count
      FROM stl_wlm_query wq
      JOIN stv_wlm_service_class_config wscc ON (wscc.service_class = wq.service_class
                                                 AND wscc.service_class > 4)
      JOIN generate_dt_series gds ON (wq.service_class_start_time <= gds.dt
                                      AND wq.service_class_end_time > gds.dt)
      WHERE wq.userid > 1
        AND wq.service_class > 4) iq
   GROUP BY iq.dt,
            iq.service_class,
            iq.num_query_tasks),
     maxes AS
  (SELECT apex.service_class,
          trunc(apex.dt) AS d,
          to_char(apex.dt, 'HH24') AS dt_h,
          MAX(service_class_slots) max_service_class_slots
   FROM apex
   GROUP BY apex.service_class,
            apex.dt,
            to_char(apex.dt, 'HH24')),
     apexes AS
  (SELECT apex.service_class,
          apex.num_query_tasks AS max_wlm_concurrency,
          maxes.d AS DAY,
          maxes.dt_h || ':00 - ' || maxes.dt_h || ':59' AS HOUR,
          MAX(apex.service_class_slots) AS max_service_class_slots
   FROM apex
   JOIN maxes ON (apex.service_class = maxes.service_class
                  AND apex.service_class_slots = maxes.max_service_class_slots)
   GROUP BY apex.service_class,
            apex.num_query_tasks,
            maxes.d,
            maxes.dt_h
   ORDER BY apex.service_class,
            maxes.d,
            maxes.dt_h)
SELECT service_class,
       "hour",
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE()) THEN max_service_class_slots
               ELSE NULL
           END) today,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-1 THEN max_service_class_slots
               ELSE NULL
           END) yesterday,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-2 THEN max_service_class_slots
               ELSE NULL
           END) two_days_ago,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-3 THEN max_service_class_slots
               ELSE NULL
           END) three_days_ago,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-4 THEN max_service_class_slots
               ELSE NULL
           END) four_days_ago,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-5 THEN max_service_class_slots
               ELSE NULL
           END) five_days_ago,
       MAX(CASE
               WHEN "day" = DATE_TRUNC('day', GETDATE())-6 THEN max_service_class_slots
               ELSE NULL
           END) six_days_ago
FROM apexes
GROUP BY service_class,
         "hour"
ORDER BY service_class,
         "hour" ;

