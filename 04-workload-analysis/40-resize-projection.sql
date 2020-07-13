/*
Usage: 
execute resizeproj(number of nodes * slices per node,number of nodes);
*/
prepare resizeproj(int,int) as
select sum(minimum_size) source_min,sum(actual_size) source_total,sum(target_min_size) target_total_min_size,sum(target_min_size)/$1 target_min_perslice,round(sum(target_min_size)*1.0/sum(actual_size),2) data_multiplier from (SELECT
    distinct b.table_id, trim(t.name) as table_name,
    CASE
        WHEN b.reldiststyle = 0 THEN (b.slices * b.columns * b.spaces)
        WHEN b.reldiststyle = 1 THEN (b.slices * b.columns * b.spaces)
        WHEN b.reldiststyle = 8 THEN (s.cns * b.columns * b.spaces)
    END minimum_size,
    CASE
        WHEN b.reldiststyle = 0 THEN ($1 * b.columns * b.spaces)
        WHEN b.reldiststyle = 1 THEN ($1 * b.columns * b.spaces)
        WHEN b.reldiststyle = 8 THEN ($2 * b.columns * b.spaces)
    END target_min_size,
    b.blocks actual_size
FROM
    (
SELECT c.reldiststyle,
COUNT(distinct slice) slices,
    COUNT(distinct col) columns,
    COUNT(DISTINCT unsorted) spaces,
    COUNT(blocknum) "blocks", tbl table_id
FROM STV_BLOCKLIST
JOIN pg_class c ON c.oid = stv_blocklist.tbl
WHERE tbl IN (
    SELECT DISTINCT id
    FROM stv_tbl_perm
    WHERE db_id > 1)
GROUP BY tbl, c.reldiststyle) b,
        (SELECT COUNT(DISTINCT node) cns, COUNT(slice) slices FROM stv_slices) s,
    stv_tbl_perm t
WHERE t.id = b.table_id) ;

