SELECT TYPE,
       node,
       SUM(used_gb) used_gb,
       SUM(capacity_gb) capacity_gb,
       ROUND((SUM(used_gb) / SUM(capacity_gb)) * 100, 1) pct_used
FROM
  (SELECT CASE capacity
              WHEN 380319 THEN 'dc1.8xlarge'
              WHEN 760956 THEN 'dc2.8xlarge'
              WHEN 190633 THEN CASE
              WHEN MOUNT LIKE '/dev/nvme%' THEN 'dc2.large'
                ELSE 'dc1.large'
              END
              WHEN 952455 THEN 'ds2.xlarge'
              WHEN 945026 THEN 'ds2.8xlarge'
              ELSE NULL
          END AS TYPE,
          OWNER "node",
                diskno "disk",
                ROUND(CAST(used - tossed AS NUMERIC) / 1024, 1) AS used_gb,
                CASE capacity
                    WHEN 380319 THEN 320
                    WHEN 760956 THEN 640
                    WHEN 190633 THEN 160
                    WHEN 952455 THEN 666
                    WHEN 945026 THEN 666
                    ELSE NULL
                END AS capacity_gb,
                ROUND((CAST(used-tossed AS NUMERIC) / CASE
                                                         WHEN capacity > 0 THEN CAST((CASE capacity
                                                                                          WHEN 380319 THEN 320
                                                                                          WHEN 760956 THEN 640
                                                                                          WHEN 190633 THEN 160
                                                                                          WHEN 952455 THEN 666
                                                                                          WHEN 945026 THEN 666
                                                                                          ELSE NULL
                                                                                      END * 1024) AS NUMERIC)
                                                         ELSE 1
                                                     END) * 100, 1) AS pct_used
   FROM stv_partitions
   WHERE OWNER = HOST
   ORDER BY OWNER,
            HOST,
            diskno) t
GROUP BY 1,
         2
ORDER BY 1,
         2;
