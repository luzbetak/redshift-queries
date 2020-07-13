SELECT a.userid,
       a.pid,
       a.node,
       a.slice,
       e.stream,
       a.seg,
       a.tasknum,
       a.query,
       d.dispatched,
       a.starttime AS segment_starts_time,
       d.starttime,
       d.endtime
FROM stl_segment_starts a
LEFT JOIN
  (SELECT b.*,
          c.slice AS globalslice
   FROM stl_segment_ends_cleanly b
   JOIN stv_slices c ON b.slice=c.localslice
   AND b.node= c.node) d ON a.slice=d.globalslice
AND a.tasknum=d.tasknum
AND a.query=d.query
AND a.pid=d.pid
AND a.seg=d.seg
LEFT JOIN stl_stream_segs e ON a.query=e.query
AND a.seg=e.segment
WHERE a.query=${queryid}
ORDER BY a.query,
         a.seg,
         a.slice"
 66     psql dev -p $PGPORT -P pager=off -c "
SELECT *
FROM stl_seg_completed_notify
WHERE query=${queryid}
ORDER BY SEGMENT,
         node,
         slice

