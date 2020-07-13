/**
  Display Redshift Data distributed on slices 
  keywords: data distribution slice
*/
SELECT trim(name) AS TABLE, stv_blocklist.slice, stv_tbl_perm.rows
FROM stv_blocklist, stv_tbl_perm
WHERE  stv_blocklist.tbl = stv_tbl_perm.id
  AND stv_tbl_perm.slice = stv_blocklist.slice
  AND name='tablename'
GROUP BY NAME, stv_blocklist.slice, stv_tbl_perm.rows
ORDER BY 2,3 DESC;

