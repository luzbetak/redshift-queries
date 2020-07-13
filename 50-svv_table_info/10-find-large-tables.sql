SELECT DATABASE,
       SCHEMA,
       "table",
       encoded,
       diststyle,
       sortkey1,
       max_varchar,
       sortkey1_enc,
       sortkey_num,
       TO_CHAR(SIZE, '999,999,999,999') SIZE,
                                        pct_used,
                                        empty,
                                        unsorted,
                                        stats_off,
                                        TO_CHAR(tbl_rows, '999,999,999,999') tbl_rows,
                                        skew_sortkey1,
                                        skew_rows
FROM svv_table_info
ORDER BY SIZE DESC
LIMIT 25;
