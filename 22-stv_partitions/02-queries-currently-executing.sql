-- The following example displays queries that are currently executing or 
-- waiting in various service classes (queues). This query is useful in tracking 
-- the overall concurrent workload for Amazon Redshift: 

select * from stv_wlm_query_state order by query;

