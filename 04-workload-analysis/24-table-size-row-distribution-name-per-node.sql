 WITH t1
     AS (SELECT a.slice,
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
                   slice)
SELECT t2.node,
       t1.tablename,
       Sum(t1.size_on_slice_mb) AS size_on_node,
       Sum(t1.rows_on_slice)    AS rows_on_node
FROM   t1
       JOIN stv_slices t2
         ON t1.slice = t2.slice
GROUP  BY t2.node,
          t1.tablename
ORDER  BY t1.tablename,
          t2.node;  
