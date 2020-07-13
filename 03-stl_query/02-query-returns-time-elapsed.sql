-- Display slowest queries for pass 1 month
-- Include elapsed time in descending order

SELECT query
    , datediff(seconds, starttime, endtime)
    , SUBSTRING(querytxt, 1, 100) AS sqlquery
FROM stl_query
WHERE starttime >= dateadd(month, -1, current_date)
ORDER BY date_diff DESC
LIMIT 20;

