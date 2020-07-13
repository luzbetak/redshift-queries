SELECT a.query,
       stream,
       a.segment,
       a.step,
       a.node,
       a.label,
       a.rrS,
       a.disk,
       c.starttime AS "compile_starttime",
       c.endtime AS "compile_endtime",
       c.compile AS "iscompiled",
       a.starttime AS "exec_starttime",
       a.endtime AS "exec_endtime",
       datediff('ms', c.endtime, a.starttime) AS "executiongaps_milsec",
       a.exec_elapsed_msecs,
       a.row_s,
       a.rows_pf,
       a.pct_filter,
       a.mem_mb,
       a.mb_produced
FROM
  (SELECT query,
          CASE
              WHEN max(slice) >= 6400 THEN 'LN'
              ELSE 'CN'
          END AS node,
          SEGMENT,
          step,
          label,
          is_rrscan AS rrS,
          is_diskbased AS disk,
          min(start_time) AS starttime,
          max(end_time) AS endtime,
          datediff(ms, min(start_time), max(end_time)) AS "exec_elapsed_msecs",
          sum(ROWS) AS row_s,
          sum(rows_pre_filter) AS rows_pf,
          CASE
              WHEN sum(rows_pre_filter) = 0 THEN 100
              ELSE sum(ROWS)::float/sum(rows_pre_filter)::float*100
          END AS pct_filter,
          SUM(workmem)/1024/1024 AS mem_mb,
          SUM(bytes)/1024/1024 AS mb_produced
   FROM svl_query_report
   WHERE query IN (657544)
   GROUP BY query,
            SEGMENT,
            step,
            label,
            is_rrscan,
            is_diskbased) a
LEFT JOIN stl_stream_segs USING (query, SEGMENT)
LEFT JOIN svl_compile c USING(query, SEGMENT)
ORDER BY a.query,
         stream,
         a.segment,
         a.step,
         a.label;
