SELECT TRIM("database") AS DB,
       COUNT(query) AS n_qry,
       MAX(SUBSTRING(qrytext, 1, 120)) AS qrytext,
       MIN(run_seconds) AS min_seconds,
       MAX(run_seconds) AS max_seconds,
       AVG(run_seconds) AS avg_seconds,
       SUM(run_seconds) AS total_seconds,
       MAX(query) AS max_query_id,
       MAX(starttime)::date AS last_run,
       aborted,
       MAX(mylabel) qry_label,
       TRIM(DECODE(event & 1, 1, 'Sortkey ', '') || DECODE(event & 2, 2, 'Deletes ', '') || DECODE(event & 4, 4, 'NL ', '') || DECODE(event & 8, 8, 'Dist ', '') || DECODE(event & 16, 16, 'Broacast ', '') || DECODE(event & 32, 32, 'Stats ', '')) AS Alert
FROM
  (SELECT userid,
          label,
          stl_query.query,
          TRIM(DATABASE) AS DATABASE,
          NVL(qrytext_cur.text, TRIM(querytxt)) AS qrytext,
          MD5(NVL(qrytext_cur.text, TRIM(querytxt))) AS qry_md5,
          starttime,
          endtime,
          DATEDIFF(seconds, starttime, endtime)::NUMERIC(12, 2) AS run_seconds,
          aborted,
          event,
          stl_query.label AS mylabel
   FROM stl_query
   LEFT OUTER JOIN
     (SELECT query,
             SUM(DECODE(TRIM(SPLIT_PART(event, ':', 1)), 'Very selective query filter', 1, 'Scanned a large number of deleted rows', 2, 'Nested Loop Join in the query plan', 4, 'Distributed a large number of rows across the network', 8, 'Broadcasted a large number of rows across the network', 16, 'Missing query planner statistics', 32, 0)) AS event
      FROM stl_alert_event_log
      WHERE event_time >= DATEADD(DAY, -7, CURRENT_DATE)
      GROUP BY query) AS alrt ON alrt.query = stl_query.query
   LEFT OUTER JOIN
     (SELECT ut.xid,
             TRIM(SUBSTRING (text
                             FROM STRPOS(UPPER(text), 'SELECT'))) AS TEXT
      FROM stl_utilitytext ut
      WHERE SEQUENCE = 0
        AND UPPER(text) LIKE 'DECLARE%'
      GROUP BY text, ut.xid) qrytext_cur ON (stl_query.xid = qrytext_cur.xid)
   WHERE userid <> 1
     AND starttime >= DATEADD(DAY, -2, CURRENT_DATE))
GROUP BY DATABASE,
         userid,
         label,
         qry_md5,
         aborted,
         event
ORDER BY total_seconds DESC
LIMIT 50;
