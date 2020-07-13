SELECT stvb.tbl,
       Trim(stvp."name")    AS tablename,
       Count(stvb.blocknum) size_in_mb
FROM   stv_blocklist stvb
       JOIN stv_tbl_perm stvp
         ON stvb.slice = stvp.slice
            AND stvb.tbl = stvp.id
WHERE  stvb.tbl > 0
GROUP  BY 1,
          2
ORDER  BY 3 DESC;  
