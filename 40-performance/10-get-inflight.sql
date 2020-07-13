SELECT a.userid,
       a.pid,
       c.xid,
       nvl(b.query, d.query) AS query,
       d.service_class,
       d.slot_count,
       27 CASE
              WHEN b.text ILIKE 'Undoing%transactions on table%' THEN 'Rollback' 28
              WHEN b.starttime IS NULL
                   AND (a.query ILIKE 'commit%'
                        OR a.query ILIKE 'end%') THEN 'Commit' 29
              WHEN d.wlm_start_time IS NOT NULL THEN initcap(d.state) 30
              WHEN c.xid IS NULL
                   OR h.leader_node_only IS NULL THEN 'Initializing' 31
              WHEN c.xid IS NOT NULL
                   AND e.granted IS FALSE THEN e.mode||'Wait on relation '||e.relation 32
              WHEN h.leader_node_only = 0 THEN 'Leader node only' 33
              WHEN c.xid IS NOT NULL
                   AND b.query IS NULL THEN 'Planning' 34
              WHEN d.wlm_start_time IS NULL THEN 'Compiling' 35
              ELSE substring(a.query, 1, 15)
          END AS query_state,
       36 a.starttime AS query_received_ts,
       b.starttime query_inflight_ts,
       d.wlm_start_time,
       getdate() AS current_ts,
       (a.duration/1000000)/86400||' days '||((a.duration/1000000)%86400)/3600||'hrs '||((a.duration/1000000)%3600)/60||'mins '||(a.duration/1000000%60)||'secs' AS duration,
       trim(a.user_name) AS user_name,
       trim(a.db_name) AS db_name,
       b.concurr ency_scaling_status,
       f.temp_blocks,
       g.num_segments,
       datediff(us, a.starttime, d.wlm_start_time) AS plantime_us,
       g.compile_us,
       d.queue_time AS queue_time_us,
       d.exec_time AS exec_time_us,
       trim(substring(translate(a.query, chr(10), ' '), 1, 75)) AS querytxt 37
FROM stv_recents a
LEFT JOIN stv_inflight b USING (pid) 38
LEFT JOIN svv_transactions c ON a.pid=c.pid
AND c.lockable_object_type='transactionid' 39
LEFT JOIN stv_wlm_query_state d ON c.xid=d.xid 40
LEFT JOIN
  (SELECT pid,
          relation::bigint,
          GRANTED,
          MODE
   FROM pg_locks
   WHERE GRANTED IS FALSE) e ON a.pid=e.pid 41
LEFT JOIN
  (SELECT query_id,
          sum(temp_blocks) AS temp_blocks
   FROM stv_query_stats
   GROUP BY 1) f ON b.query=f.query_id 42
LEFT JOIN
  (SELECT query,
          count(SEGMENT) AS num_segments,
          sum(datediff(us, starttime, endtime)) compile_us
   FROM svl_compile
   GROUP BY 1) g ON d.query=g.query 43
LEFT JOIN
  (SELECT pid,
          sum(CASE
                  WHEN relation < 17500 THEN 0
                  ELSE 1
              END) AS leader_node_only
   FROM pg_locks
   WHERE DATABASE IS NOT NULL
   GROUP BY 1) h ON a.pid=h.pid 44
WHERE a.status='Running'
ORDER BY query_received_ts

