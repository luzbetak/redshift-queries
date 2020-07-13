/*
	Per Slice
*/
SELECT slice,
       Count(blocknum)              size_on_slice_mb,
       (SELECT Sum(num_values)
        FROM   stv_blocklist
        WHERE  tbl = a.tbl
               AND col = 0
               AND slice = a.slice) rows_on_slice
FROM   stv_blocklist a
WHERE  tbl = 151528
GROUP  BY slice,
          tbl
ORDER  BY slice;  
