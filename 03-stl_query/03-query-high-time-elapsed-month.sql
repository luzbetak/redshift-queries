-- Display queries in elapsed time in descending order

SELECT query
    , datediff(seconds, starttime, endtime)
    , SUBSTRING(querytxt, 1, 100) AS sqlquery
FROM stl_query
WHERE starttime >= date(current_date - cast('1 month' as interval)) 
ORDER BY date_diff DESC
LIMIT 20;

