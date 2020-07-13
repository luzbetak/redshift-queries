SELECT *
FROM   stl_wlm_rule_action
WHERE  query IN
SELECT service_class,
       trim(rule_name)   AS rule_name,
       trim(action)      AS action,
       trim(metric_name) AS metric_name,
       metric_operator,
       metric_value
FROM   pg_catalog.stv_wlm_qmr_config; 

