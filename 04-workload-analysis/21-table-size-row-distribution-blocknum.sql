SELECT slice,
       col,
       Count(blocknum) size_on_slice_mb,
       Sum(num_values) rows_on_slice,
       Min(minvalue),
       Max(maxvalue)
FROM   stv_blocklist
WHERE  tbl = 187206
GROUP  BY slice,
          col
ORDER  BY slice,
          col;  
