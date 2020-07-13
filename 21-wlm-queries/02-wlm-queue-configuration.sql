SELECT wlm.service_class queue,
       TRIM(wlm.name) queue_name,
       LISTAGG(TRIM(cnd.condition), ', ') CONDITION,
                                          wlm.num_query_tasks query_concurrency,
                                          wlm.query_working_mem per_query_memory_mb,
                                          ROUND(((wlm.num_query_tasks*wlm.query_working_mem)::NUMERIC/mem.total_mem::NUMERIC)*100, 0)::INT cluster_memory_pct,
                                          wlm.max_execution_time,
                                          wlm.user_group_wild_card,
                                          wlm.query_group_wild_card
FROM stv_wlm_service_class_config wlm
JOIN stv_wlm_classification_config cnd ON wlm.service_class = cnd.action_service_class
CROSS JOIN
  (SELECT SUM(num_query_tasks*query_working_mem) total_mem
   FROM pg_catalog.stv_wlm_service_class_config
   WHERE service_class BETWEEN 6 AND 13) mem
WHERE wlm.service_class > 5
GROUP BY wlm.service_class,
         TRIM(wlm.name),
         wlm.num_query_tasks,
         wlm.query_working_mem,
         mem.total_mem,
         wlm.max_execution_time,
         wlm.user_group_wild_card,
         wlm.query_group_wild_card
ORDER BY 1 ;
