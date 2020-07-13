SELECT qmr.service_class queue,
       TRIM(wlm.name) queue_name,
       TRIM(rule_name) rule_name,
       TRIM(action) AS action,
       TRIM(metric_name)||' '||TRIM(metric_operator)||' '||metric_value AS RULE
FROM stv_wlm_qmr_config qmr
JOIN stv_wlm_service_class_config wlm USING (service_class)
WHERE qmr.service_class > 5
ORDER BY qmr.service_class,
         TRIM(rule_name);

