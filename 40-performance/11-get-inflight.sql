SELECT a.txn_owner,
       a.txn_db,
       a.xid,
       a.pid,
       a.txn_start,
       a.lock_mode,
       a.relation AS table_id,
       nvl(trim(c.\"name\"),d.relname) as tablename, a.granted,b.pid as blocking_pid ,datediff(s,a.txn_start,getdate())/86400||' days '||datediff(s,a.txn_start,getdate())%86400/3600||' hrs '||datediff(s,a.txn_s    tart,getdate())%3600/60||' mins '||datediff(s,a.txn_start,getdate())%60||' secs' as txn_duration from (SELECT rtrim(s.user_name::text) AS txn_owner, rtrim(s.db_name::text) AS txn_db, t.xid, t.pid::integer AS pid, t.start_ts AS txn_start, trim(l.\"mode\") AS lock_mode, CASE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       WHEN l.relation IS NULL THEN 'transactionid'::text
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ELSE 'relati    on'::text
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   END::CHARACTER varying(14) AS lockable_object_type, l.relation::integer AS relation, l.granted
           FROM stv_transactions t
           LEFT JOIN pg_locks l ON l.pid = t.pid
           LEFT JOIN stv_sessions s ON s.process = t.pid
           WHERE t.ended = 0
           ORDER BY t.start_ts, t.xid, l.granted, l.relation) a
LEFT JOIN
  (SELECT pid,
          relation,
          GRANTED
   FROM pg_locks
   GROUP BY 1,
            2,
            3) b ON a.relation=b.relation
AND a.granted='f'
AND b.granted='t'
LEFT JOIN
  (SELECT *
   FROM stv_tbl_perm
   WHERE slice=0) c ON a.relation=c.id
LEFT JOIN pg_class d ON a.relation=d.oid
WHERE a.relation IS NOT NULL;


