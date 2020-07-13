 SELECT a.slice,
       a.tbl,
       Trim(b."name")    AS tablename,
       Count(a.blocknum) size_on_slice_mb,
       b.rows            rows_on_slice
FROM   stv_blocklist a
       JOIN stv_tbl_perm b
         ON a.tbl = b.id
            AND a.slice = b.slice
WHERE  a.tbl > 0
GROUP  BY 1,
          2,
          3,
          5
ORDER  BY tbl,
          slice;  
