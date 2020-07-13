-- Find Scanned Tables
SELECT SCHEMA
	,"table"
	,encoded
	,diststyle
	,sortkey1
	-- ,max_varchar
	,sortkey1_enc
	,sortkey_num
	,TO_CHAR(size, '999,999,999,999') size
	-- ,pct_used
	-- ,empty
	,unsorted
	,stats_off
	,TO_CHAR(tbl_rows, '999,999,999,999') tbl_rows
-- ,skew_sortkey1
-- ,skew_rows
FROM svv_table_info
WHERE table_id IN (
		SELECT DISTINCT tbl
		FROM stl_scan
		WHERE -- perm_table_name != 'Internal Worktable'
			query = 35870085
		)
-- AND diststyle!='ALL' 
ORDER BY tbl_rows DESC;

