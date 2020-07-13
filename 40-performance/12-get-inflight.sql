SELECT *,
       datediff(s, starttime, getdate())
FROM stv_inflight
ORDER BY starttime;

